<?php

class ProductionBatchController {
    private $db;

    public function __construct($db) {
        $this->db = $db;
    }

    // Get all batches
    public function getAll() {
        try {
            $query = "
                SELECT 
                    pb.*,
                    p.name as product_name,
                    p.category,
                    p.unit,
                    GROUP_CONCAT(
                        DISTINCT CASE WHEN bw.role_type = 'supervisor' 
                        THEN CONCAT(bw.user_id, ':', u.name) 
                        END SEPARATOR '||'
                    ) as supervisors,
                    GROUP_CONCAT(
                        DISTINCT CASE WHEN bw.role_type = 'worker' 
                        THEN CONCAT(bw.user_id, ':', u.name) 
                        END SEPARATOR '||'
                    ) as workers
                FROM production_batches pb
                JOIN products p ON pb.product_id = p.product_id
                LEFT JOIN batch_workers bw ON pb.batch_id = bw.batch_id
                LEFT JOIN users u ON bw.user_id = u.user_id
                GROUP BY pb.batch_id
                ORDER BY pb.scheduled_date DESC, pb.batch_id DESC
            ";
            
            $stmt = $this->db->prepare($query);
            $stmt->execute();
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            $batches = [];
            foreach ($rows as $row) {
                // Parse supervisors
                $supervisorIds = [];
                $supervisorNames = [];
                if (!empty($row['supervisors'])) {
                    foreach (explode('||', $row['supervisors']) as $supervisor) {
                        if (!empty($supervisor)) {
                            list($id, $name) = explode(':', $supervisor);
                            $supervisorIds[] = (int)$id;
                            $supervisorNames[] = $name;
                        }
                    }
                }
                
                // Parse workers
                $workerIds = [];
                $workerNames = [];
                if (!empty($row['workers'])) {
                    foreach (explode('||', $row['workers']) as $worker) {
                        if (!empty($worker)) {
                            list($id, $name) = explode(':', $worker);
                            $workerIds[] = (int)$id;
                            $workerNames[] = $name;
                        }
                    }
                }
                
                $batches[] = [
                    'batch_id' => (int)$row['batch_id'],
                    'batch_number' => $row['batch_number'],
                    'product_id' => (int)$row['product_id'],
                    'product_name' => $row['product_name'],
                    'category' => $row['category'],
                    'unit' => $row['unit'],
                    'target_quantity' => (float)$row['target_quantity'],
                    'scheduled_date' => $row['scheduled_date'],
                    'status' => $row['status'],
                    'current_stage' => $row['current_stage'],
                    'notes' => $row['notes'],
                    'supervisor_ids' => $supervisorIds,
                    'supervisor_names' => $supervisorNames,
                    'worker_ids' => $workerIds,
                    'worker_names' => $workerNames,
                    'created_at' => $row['created_at'],
                    'updated_at' => $row['updated_at']
                ];
            }
            
            return [
                'success' => true,
                'data' => $batches
            ];
            
        } catch (Exception $e) {
            error_log("Error in getAll: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Failed to retrieve batches: ' . $e->getMessage()
            ];
        }
    }

    // Create new batch
    public function create($data) {
        try {
            // Generate batch number
            $batchNumber = 'PB-' . date('Y') . '-' . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);
            
            $query = "
                INSERT INTO production_batches 
                (batch_number, product_id, target_quantity, scheduled_date, status, current_stage, notes)
                VALUES (:batch_number, :product_id, :target_quantity, :scheduled_date, :status, :current_stage, :notes)
            ";
            
            $stmt = $this->db->prepare($query);
            $status = $data['status'] ?? 'planned';
            $stage = $data['current_stage'] ?? 'mixing';
            
            $stmt->execute([
                ':batch_number' => $batchNumber,
                ':product_id' => $data['product_id'],
                ':target_quantity' => $data['target_quantity'],
                ':scheduled_date' => $data['scheduled_date'],
                ':status' => $status,
                ':current_stage' => $stage,
                ':notes' => $data['notes'] ?? null
            ]);
            
            $batchId = $this->db->lastInsertId();
            
            // Assign workers
            if (!empty($data['supervisor_ids'])) {
                foreach ($data['supervisor_ids'] as $userId) {
                    $this->assignWorker($batchId, $userId, 'supervisor');
                }
            }
            
            if (!empty($data['worker_ids'])) {
                foreach ($data['worker_ids'] as $userId) {
                    $this->assignWorker($batchId, $userId, 'worker');
                }
            }
            
            return [
                'success' => true,
                'message' => 'Batch created successfully',
                'batch_id' => $batchId,
                'batch_number' => $batchNumber
            ];
            
        } catch (Exception $e) {
            error_log("Error in create: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Failed to create batch: ' . $e->getMessage()
            ];
        }
    }

    // Update batch
    public function update($batchId, $data) {
        try {
            $query = "
                UPDATE production_batches 
                SET product_id = :product_id, 
                    target_quantity = :target_quantity, 
                    scheduled_date = :scheduled_date, 
                    status = :status, 
                    current_stage = :current_stage, 
                    notes = :notes
                WHERE batch_id = :batch_id
            ";
            
            $stmt = $this->db->prepare($query);
            $stmt->execute([
                ':product_id' => $data['product_id'],
                ':target_quantity' => $data['target_quantity'],
                ':scheduled_date' => $data['scheduled_date'],
                ':status' => $data['status'],
                ':current_stage' => $data['current_stage'],
                ':notes' => $data['notes'] ?? null,
                ':batch_id' => $batchId
            ]);
            
            // Update workers if provided
            if (isset($data['supervisor_ids']) || isset($data['worker_ids'])) {
                // Clear existing assignments
                $deleteQuery = "DELETE FROM batch_workers WHERE batch_id = :batch_id";
                $deleteStmt = $this->db->prepare($deleteQuery);
                $deleteStmt->execute([':batch_id' => $batchId]);
                
                // Re-assign workers
                if (!empty($data['supervisor_ids'])) {
                    foreach ($data['supervisor_ids'] as $userId) {
                        $this->assignWorker($batchId, $userId, 'supervisor');
                    }
                }
                
                if (!empty($data['worker_ids'])) {
                    foreach ($data['worker_ids'] as $userId) {
                        $this->assignWorker($batchId, $userId, 'worker');
                    }
                }
            }
            
            return [
                'success' => true,
                'message' => 'Batch updated successfully'
            ];
            
        } catch (Exception $e) {
            error_log("Error in update: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Failed to update batch: ' . $e->getMessage()
            ];
        }
    }

    // Delete batch
    public function delete($batchId) {
        try {
            $query = "DELETE FROM production_batches WHERE batch_id = :batch_id";
            $stmt = $this->db->prepare($query);
            $stmt->execute([':batch_id' => $batchId]);
            
            return [
                'success' => true,
                'message' => 'Batch deleted successfully'
            ];
            
        } catch (Exception $e) {
            error_log("Error in delete: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Failed to delete batch: ' . $e->getMessage()
            ];
        }
    }

    // Update batch stage
    public function updateStage($batchId, $stage) {
        try {
            $query = "UPDATE production_batches SET current_stage = :stage WHERE batch_id = :batch_id";
            $stmt = $this->db->prepare($query);
            $stmt->execute([
                ':stage' => $stage,
                ':batch_id' => $batchId
            ]);
            
            return [
                'success' => true,
                'message' => 'Stage updated successfully'
            ];
            
        } catch (Exception $e) {
            error_log("Error in updateStage: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Failed to update stage: ' . $e->getMessage()
            ];
        }
    }

    // Update batch status
    public function updateStatus($batchId, $status) {
        try {
            $query = "UPDATE production_batches SET status = :status WHERE batch_id = :batch_id";
            $stmt = $this->db->prepare($query);
            $stmt->execute([
                ':status' => $status,
                ':batch_id' => $batchId
            ]);
            
            return [
                'success' => true,
                'message' => 'Status updated successfully'
            ];
            
        } catch (Exception $e) {
            error_log("Error in updateStatus: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Failed to update status: ' . $e->getMessage()
            ];
        }
    }

    // Helper method to assign worker
    private function assignWorker($batchId, $userId, $roleType) {
        $query = "INSERT INTO batch_workers (batch_id, user_id, role_type) VALUES (:batch_id, :user_id, :role_type)";
        $stmt = $this->db->prepare($query);
        $stmt->execute([
            ':batch_id' => $batchId,
            ':user_id' => $userId,
            ':role_type' => $roleType
        ]);
    }
}

