# PhamMinhTai_IT202_Session11_bai3

# BÁO CÁO PHÂN TÍCH HỆ THỐNG

## Bài 3 - Tính chi phí xuất viện

---

# 1. Mô tả bài toán

Trong quy trình xuất viện tại phòng khám, nhân viên thu ngân cần tính số tiền cuối cùng bệnh nhân phải thanh toán.

Hiện tại việc tính toán đang thực hiện thủ công bằng máy tính tay.

Điều này dễ dẫn đến:

* Sai sót khi giảm giá
* Nhập nhầm số tiền
* Thất thoát doanh thu
* Không đồng nhất giữa các nhân viên

Ban quản lý yêu cầu xây dựng một Stored Procedure tự động tính chi phí xuất viện.

Thu ngân chỉ cần nhập:

* Tổng chi phí điều trị
* Diện bệnh nhân

Hệ thống sẽ tự động:

* Tính số tiền cuối cùng cần thanh toán
* Trả thông báo trạng thái

---

# 2. Quy tắc nghiệp vụ

Hệ thống hỗ trợ 3 diện bệnh nhân:

| Diện bệnh nhân | Quy tắc                       |
| -------------- | ----------------------------- |
| BHYT           | Hỗ trợ 80%, bệnh nhân trả 20% |
| VIP            | Giảm giá 10%                  |
| THUONG         | Thanh toán 100%               |

Ngoài ra:

* Nếu tổng chi phí là số âm
  → Không được phép tính toán.

Hệ thống phải:

* Trả số tiền = 0
* Trả thông báo lỗi

---

# 3. Phân tích Input / Output

## 3.1 Dữ liệu đầu vào

| Tham số        | Ý nghĩa               |
| -------------- | --------------------- |
| p_total_cost   | Tổng chi phí điều trị |
| p_patient_type | Diện bệnh nhân        |

---

## 3.2 Dữ liệu đầu ra

| Tham số        | Ý nghĩa                    |
| -------------- | -------------------------- |
| p_final_amount | Số tiền cuối cùng phải thu |
| p_message      | Thông báo trạng thái       |

---

# 4. Phân tích loại tham số

## IN Parameters

Dùng để:

* Nhận dữ liệu từ người dùng
* Truyền dữ liệu vào Procedure

Bao gồm:

```sql
IN p_total_cost
IN p_patient_type
```

---

## OUT Parameters

Dùng để:

* Trả kết quả tính toán
* Trả trạng thái xử lý

Bao gồm:

```sql
OUT p_final_amount
OUT p_message
```

---

# 5. Hướng giải quyết

## Bước 1

Kiểm tra dữ liệu đầu vào.

Nếu:

```sql
p_total_cost < 0
```

→ Báo lỗi.

---

## Bước 2

Nếu dữ liệu hợp lệ:

* BHYT → thu 20%
* VIP → giảm 10%
* THUONG → thu đủ 100%

---

## Bước 3

Trả kết quả:

* Số tiền cuối cùng
* Thông báo trạng thái

---

# 6. Procedure triển khai

```sql
DROP PROCEDURE IF EXISTS CalculateDischargeCost;

DELIMITER //

CREATE PROCEDURE CalculateDischargeCost(

    IN p_total_cost DECIMAL(18,2),
    IN p_patient_type VARCHAR(20),

    OUT p_final_amount DECIMAL(18,2),
    OUT p_message VARCHAR(255)
)
BEGIN

    IF p_total_cost < 0 THEN

        SET p_final_amount = 0;
        SET p_message = 'Loi: Chi phi khong hop le';

    ELSE

        IF p_patient_type = 'BHYT' THEN

            SET p_final_amount = p_total_cost * 0.2;

        ELSEIF p_patient_type = 'VIP' THEN

            SET p_final_amount = p_total_cost * 0.9;

        ELSE

            SET p_final_amount = p_total_cost;

        END IF;

        SET p_message = 'Da tinh toan xong';

    END IF;

END //

DELIMITER ;
```

---

# 7. Giải thích logic hoạt động

## 7.1 Kiểm tra lỗi dữ liệu

Procedure đầu tiên kiểm tra:

```sql
IF p_total_cost < 0
```

Nếu đúng:

* Không thực hiện tính toán
* Trả lỗi

Điều này giúp ngăn:

* Dữ liệu sai
* Gian lận hệ thống
* Sai lệch tài chính

---

## 7.2 Tính toán theo diện bệnh nhân

### Trường hợp BHYT

```sql
SET p_final_amount = p_total_cost * 0.2;
```

Bệnh nhân chỉ thanh toán 20%.

---

### Trường hợp VIP

```sql
SET p_final_amount = p_total_cost * 0.9;
```

Giảm giá 10%.

---

### Trường hợp THUONG

```sql
SET p_final_amount = p_total_cost;
```

Thanh toán toàn bộ.

---

# 8. Kiểm thử hệ thống

## 8.1 Test BHYT

### Input

```sql
CALL CalculateDischargeCost(
    1000000,
    'BHYT',
    @final_amount,
    @message
);
```

### Kết quả mong muốn

| final_amount | message           |
| ------------ | ----------------- |
| 200000       | Da tinh toan xong |

---

## 8.2 Test VIP

### Input

```sql
CALL CalculateDischargeCost(
    1000000,
    'VIP',
    @final_amount,
    @message
);
```

### Kết quả mong muốn

| final_amount | message           |
| ------------ | ----------------- |
| 900000       | Da tinh toan xong |

---

## 8.3 Test THUONG

### Input

```sql
CALL CalculateDischargeCost(
    1000000,
    'THUONG',
    @final_amount,
    @message
);
```

### Kết quả mong muốn

| final_amount | message           |
| ------------ | ----------------- |
| 1000000      | Da tinh toan xong |

---

## 8.4 Test dữ liệu âm

### Input

```sql
CALL CalculateDischargeCost(
    -500000,
    'VIP',
    @final_amount,
    @message
);
```

### Kết quả mong muốn

| final_amount | message                   |
| ------------ | ------------------------- |
| 0            | Loi: Chi phi khong hop le |

---

# 9. Kết luận

Hệ thống cũ phụ thuộc vào thao tác thủ công nên dễ gây sai sót tài chính.

Việc triển khai Stored Procedure giúp:

* Chuẩn hóa nghiệp vụ
* Giảm sai sót nhập liệu
* Tự động hóa tính toán
* Bảo vệ doanh thu
* Tăng tốc xử lý xuất viện

Sau khi triển khai:

* Thu ngân chỉ cần nhập dữ liệu đầu vào.
* Database tự xử lý toàn bộ logic.
* Frontend chỉ việc hiển thị kết quả.

---

# 10. Tổng kết kỹ thuật

| Thành phần         | Nội dung                  |
| ------------------ | ------------------------- |
| Loại bài toán      | Business Logic Automation |
| Kỹ thuật sử dụng   | Stored Procedure          |
| Loại tham số       | IN + OUT                  |
| Kiểm tra dữ liệu   | IF condition              |
| Rẽ nhánh nghiệp vụ | IF / ELSEIF               |
| Giá trị mang lại   | Tự động hóa tính phí      |
| Mức độ ảnh hưởng   | Cao                       |
