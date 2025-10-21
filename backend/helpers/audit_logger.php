<?php
/**
 * Audit Logger
 * Tracks all important changes in the system
 */

class AuditLogger {
    private $db;
    
    public function __construct($db) {
        $this->db = $db;
    }
    
    /**
     * Log an audit event
     */
    public function log($userId, $action, $entityType, $entityId, $details = null, $ipAddress = null) {
        try {
            $query = "INSERT INTO audit_logs 
                     (user_id, action, entity_type, entity_id, details, ip_address, created_at) 
                     VALUES 
                     (:user_id, :action, :entity_type, :entity_id, :details, :ip_address, NOW())";
            
            $stmt = $this->db->prepare($query);
            $stmt->bindParam(':user_id', $userId);
            $stmt->bindParam(':action', $action);
            $stmt->bindParam(':entity_type', $entityType);
            $stmt->bindParam(':entity_id', $entityId);
            
            $detailsJson = $details ? json_encode($details) : null;
            $stmt->bindParam(':details', $detailsJson);
            
            $ip = $ipAddress ?: $this->getClientIP();
            $stmt->bindParam(':ip_address', $ip);
            
            return $stmt->execute();
        } catch (PDOException $e) {
            error_log("Audit log failed: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Get client IP address
     */
    private function getClientIP() {
        if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
            return $_SERVER['HTTP_CLIENT_IP'];
        } elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            return $_SERVER['HTTP_X_FORWARDED_FOR'];
        } else {
            return $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        }
    }
    
    /**
     * Get audit logs with filters
     */
    public function getLogs($filters = []) {
        $query = "SELECT al.*, u.name as user_name, u.email as user_email 
                 FROM audit_logs al 
                 LEFT JOIN users u ON al.user_id = u.user_id 
                 WHERE 1=1";
        
        $params = [];
        
        if (isset($filters['user_id'])) {
            $query .= " AND al.user_id = :user_id";
            $params[':user_id'] = $filters['user_id'];
        }
        
        if (isset($filters['entity_type'])) {
            $query .= " AND al.entity_type = :entity_type";
            $params[':entity_type'] = $filters['entity_type'];
        }
        
        if (isset($filters['action'])) {
            $query .= " AND al.action = :action";
            $params[':action'] = $filters['action'];
        }
        
        if (isset($filters['start_date'])) {
            $query .= " AND al.created_at >= :start_date";
            $params[':start_date'] = $filters['start_date'];
        }
        
        if (isset($filters['end_date'])) {
            $query .= " AND al.created_at <= :end_date";
            $params[':end_date'] = $filters['end_date'];
        }
        
        $query .= " ORDER BY al.created_at DESC";
        
        if (isset($filters['limit'])) {
            $query .= " LIMIT " . intval($filters['limit']);
        }
        
        $stmt = $this->db->prepare($query);
        
        foreach ($params as $key => $value) {
            $stmt->bindValue($key, $value);
        }
        
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    /**
     * Get audit log statistics
     */
    public function getStats($startDate = null, $endDate = null) {
        $query = "SELECT 
                    COUNT(*) as total_logs,
                    COUNT(DISTINCT user_id) as unique_users,
                    COUNT(CASE WHEN action = 'CREATE' THEN 1 END) as creates,
                    COUNT(CASE WHEN action = 'UPDATE' THEN 1 END) as updates,
                    COUNT(CASE WHEN action = 'DELETE' THEN 1 END) as deletes,
                    COUNT(CASE WHEN action = 'LOGIN' THEN 1 END) as logins
                 FROM audit_logs 
                 WHERE 1=1";
        
        if ($startDate) {
            $query .= " AND created_at >= '$startDate'";
        }
        
        if ($endDate) {
            $query .= " AND created_at <= '$endDate'";
        }
        
        $stmt = $this->db->query($query);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
}

