-- =========================================
-- [VẬN DỤNG CHUYÊN SÂU]
-- TÍNH CHI PHÍ XUẤT VIỆN
-- =========================================

-- =========================================
-- PHẦN 1: PHÂN TÍCH
-- =========================================

-- INPUT:
-- p_total_cost     : Tổng chi phí điều trị
-- p_patient_type   : Diện bệnh nhân
--                    ('BHYT', 'VIP', 'THUONG')

-- OUTPUT:
-- p_final_amount   : Số tiền cuối cùng phải thu
-- p_message        : Thông báo trạng thái

-- =========================================
-- LOẠI THAM SỐ ĐỀ XUẤT
-- =========================================

-- IN:
-- Nhận dữ liệu đầu vào từ người dùng

-- OUT:
-- Trả kết quả tính toán và thông báo ra ngoài

-- =========================================
-- GIẢI PHÁP
-- =========================================

-- Bước 1:
-- Kiểm tra tổng chi phí có hợp lệ không

-- Nếu < 0:
--   - final_amount = 0
--   - message = 'Lỗi: Chi phí không hợp lệ'

-- Bước 2:
-- Nếu hợp lệ:
--   - BHYT    -> thu 20%
--   - VIP     -> giảm 10%
--   - THUONG  -> thu 100%

-- Bước 3:
-- Trả về:
--   - số tiền cuối cùng
--   - thông báo trạng thái

-- =========================================
-- PHẦN 2: TRIỂN KHAI PROCEDURE
-- =========================================

DROP PROCEDURE IF EXISTS CalculateDischargeCost;

DELIMITER //

CREATE PROCEDURE CalculateDischargeCost(
    IN p_total_cost DECIMAL(18,2),
    IN p_patient_type VARCHAR(20),

    OUT p_final_amount DECIMAL(18,2),
    OUT p_message VARCHAR(255)
)
BEGIN

    -- =====================================
    -- KIỂM TRA CHI PHÍ ÂM
    -- =====================================

    IF p_total_cost < 0 THEN

        SET p_final_amount = 0;
        SET p_message = 'Loi: Chi phi khong hop le';

    ELSE

        -- =================================
        -- BHYT
        -- =================================

        IF p_patient_type = 'BHYT' THEN

            SET p_final_amount = p_total_cost * 0.2;

        -- =================================
        -- VIP
        -- =================================

        ELSEIF p_patient_type = 'VIP' THEN

            SET p_final_amount = p_total_cost * 0.9;

        -- =================================
        -- THUONG
        -- =================================

        ELSE

            SET p_final_amount = p_total_cost;

        END IF;

        SET p_message = 'Da tinh toan xong';

    END IF;

END //

DELIMITER ;

-- =========================================
-- PHẦN 3: KIỂM THỬ
-- =========================================

-- =========================================
-- TEST 1: BHYT
-- Tổng viện phí: 1,000,000
-- Chỉ trả 20%
-- Kết quả mong muốn: 200,000
-- =========================================

CALL CalculateDischargeCost(
    1000000,
    'BHYT',
    @final_amount,
    @message
);

SELECT @final_amount AS final_amount,
       @message AS message;

-- =========================================
-- TEST 2: VIP
-- Giảm 10%
-- Kết quả mong muốn: 900,000
-- =========================================

CALL CalculateDischargeCost(
    1000000,
    'VIP',
    @final_amount,
    @message
);

SELECT @final_amount AS final_amount,
       @message AS message;

-- =========================================
-- TEST 3: THUONG
-- Đóng 100%
-- Kết quả mong muốn: 1,000,000
-- =========================================

CALL CalculateDischargeCost(
    1000000,
    'THUONG',
    @final_amount,
    @message
);

SELECT @final_amount AS final_amount,
       @message AS message;

-- =========================================
-- TEST 4: LỖI CHI PHÍ ÂM
-- Kết quả mong muốn:
-- final_amount = 0
-- message = 'Loi: Chi phi khong hop le'
-- =========================================

CALL CalculateDischargeCost(
    -500000,
    'VIP',
    @final_amount,
    @message
);

SELECT @final_amount AS final_amount,
       @message AS message;