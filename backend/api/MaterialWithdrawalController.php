<?php

class MaterialWithdrawalController {
    private $db;

    public function __construct($db) {
        $this->db = $db;
    }

    // Get all withdrawals
    public function getAll() {
        try {
            $query = "
                SELECT 
                    mw.*,
                    p.name as product_name,
                    p.category,
                    p.unit,
                    i.quantity as available_stock,
                    i.location,
                    u_req.name as requested_by_name,
                    u_req.email as requested_by_email,
                    u_app.name as approved_by_name,
                    pb.batch_number
                FROM material_withdrawals mw
                JOIN inventory i ON mw.inventory_id = i.inventory_id
                JOIN products p ON i.product_id = p.product_id
                JOIN users u_req ON mw.requested_by = u_req.user_id
                LEFT JOIN users u_app ON mw.approved_by = u_app.user_id
                LEFT JOIN production_batches pb ON mw.batch_id = pb.batch_id
                ORDER BY mw.requested_at DESC
            ";
            
            $stmt = $this->db->prepare($query);
            $stmt->execute();
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            $withdrawals = [];
            foreach ($rows as $row) {
                $withdrawals[] = [
                    'withdrawal_id' => (int)$row['withdrawal_id'],
                    'inventory_id' => (int)$row['inventory_id'],
                    'product_name' => $row['product_name'],
                    'category' => $row['category'],
                    'unit' => $row['unit'],
                    'requested_quantity' => (float)$row['requested_quantity'],
                    'available_stock' => (float)$row['available_stock'],
                    'location' => $row['location'],
                    'requested_by' => (int)$row['requested_by'],
                    'requested_by_name' => $row['requested_by_name'],
                    'requested_by_email' => $row['requested_by_email'],
                    'batch_id' => $row['batch_id'] ? (int)$row['batch_id'] : null,
                    'batch_number' => $row['batch_number'],
                    'purpose' => $row['purpose'],
                    'status' => $row['status'],
                    'requested_at' => $row['requested_at'],
                    'approved_by' => $row['approved_by'] ? (int)$row['approved_by'] : null,
                    'approved_by_name' => $row['approved_by_name'],
                    'approved_at' => $row['approved_at'],
                    'rejection_reason' => $row['rejection_reason']
                ];
            }
            
            return [
                'success' => true,
                'data' => $withdrawals
            ];
            
        } catch (Exception $e) {
            error_log("Error in getAll: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Failed to retrieve withdrawals: ' . $e->getMessage()
            ];
        }
    }

    // Create withdrawal request
    public function create($data) {
        try {
            $query = "
                INSERT INTO material_withdrawals 
                (inventory_id, requested_quantity, requested_by, batch_id, purpose, status)
                VALUES (:inventory_id, :requested_quantity, :requested_by, :batch_id, :purpose, :status)
            ";
            
            $stmt = $this->db->prepare($query);
            $stmt->execute([
                ':inventory_id' => $data['inventory_id'],
                ':requested_quantity' => $data['requested_quantity'],
                ':requested_by' => $data['requested_by'],
                ':batch_id' => $data['batch_id'] ?? null,
                ':purpose' => $data['purpose'] ?? null,
                ':status' => 'pending'
            ]);
            
            $withdrawalId = $this->db->lastInsertId();
            
            return [
                'success' => true,
                'message' => 'Withdrawal request created successfully',
                'withdrawal_id' => $withdrawalId
            ];
            
        } catch (Exception $e) {
            error_log("Error in create: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Failed to create withdrawal: ' . $e->getMessage()
            ];
        }
    }

    // Approve withdrawal
    public function approve($withdrawalId, $approvedBy) {
        try {
            // Get withdrawal details
            $query = "SELECT inventory_id, requested_quantity FROM material_withdrawals WHERE withdrawal_id = :id";
            $stmt = $this->db->prepare($query);
            $stmt->execute([':id' => $withdrawalId]);
            $withdrawal = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$withdrawal) {
                throw new Exception('Withdrawal not found');
            }
            
            // Update withdrawal status
            $query = "
                UPDATE material_withdrawals 
                SET status = 'approved', 
                    approved_by = :approved_by, 
                    approved_at = NOW()
                WHERE withdrawal_id = :id
            ";
            $stmt = $this->db->prepare($query);
            $stmt->execute([
                ':approved_by' => $approvedBy,
                ':id' => $withdrawalId
            ]);
            
            // Deduct from inventory
            $query = "UPDATE inventory SET quantity = quantity - :qty WHERE inventory_id = :inv_id";
            $stmt = $this->db->prepare($query);
            $stmt->execute([
                ':qty' => $withdrawal['requested_quantity'],
                ':inv_id' => $withdrawal['inventory_id']
            ]);
            
            return [
                'success' => true,
                'message' => 'Withdrawal approved and inventory updated'
            ];
            
        } catch (Exception $e) {
            error_log("Error in approve: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Failed to approve withdrawal: ' . $e->getMessage()
            ];
        }
    }

    // Reject withdrawal
    public function reject($withdrawalId, $approvedBy, $reason) {
        try {
            $query = "
                UPDATE material_withdrawals 
                SET status = 'rejected', 
                    approved_by = :approved_by, 
                    approved_at = NOW(),
                    rejection_reason = :reason
                WHERE withdrawal_id = :id
            ";
            
            $stmt = $this->db->prepare($query);
            $stmt->execute([
                ':approved_by' => $approvedBy,
                ':reason' => $reason,
                ':id' => $withdrawalId
            ]);
            
            return [
                'success' => true,
                'message' => 'Withdrawal rejected'
            ];
            
        } catch (Exception $e) {
            error_log("Error in reject: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Failed to reject withdrawal: ' . $e->getMessage()
            ];
        }
    }
}

