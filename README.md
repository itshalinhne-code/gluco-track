# 🏥 *Gluco Track - Hệ thống quản lý y tế thông minh*

## 📌 *Giới thiệu tổng quan*

*Gluco Track* là hệ thống y tế số toàn diện bao gồm 2 ứng dụng di động:

- *Gluco Track Doctor*: Dành cho bác sĩ quản lý lịch khám, kê đơn thuốc và theo dõi bệnh nhân
- *Gluco Track User*: Dành cho bệnh nhân đặt lịch khám, quản lý sức khỏe và hồ sơ y tế

Hệ thống kết nối bác sĩ và bệnh nhân, tối ưu hóa quy trình khám chữa bệnh và nâng cao chất lượng dịch vụ y tế.

🎯 *"Quản lý thông minh - Chăm sóc chuyên nghiệp - Kết nối hiệu quả!"*

---

## 📥 *Download & Demo*

### Gluco Track Doctor (Ứng dụng Bác sĩ)
- *[DOWNLOAD APP](https://drive.google.com/file/d/1WOkJJjci_H-vsdLRpgvaRVsVMwZYOQFI/view?usp=drive_link)*
- *[LINK DEMO](https://drive.google.com/file/d/1wrl1VGeH8GxvUu52GcWtrs8uwoFDMHd2/view?usp=drivesdk&usp=embed_facebook)*

### Gluco Track User (Ứng dụng Bệnh nhân)
- *[DOWNLOAD APP](https://drive.google.com/file/d/1uE1drj4xyq0rjby-usFv7IHjXFRufKvh/view?usp=drive_link)*
- *[LINK DEMO](#)*
(Đang cập nhật)

---

## 🎯 *Mục tiêu hệ thống*

- Số hóa quy trình khám chữa bệnh
- Tối ưu hóa quản lý lịch hẹn và hồ sơ bệnh án
- Kê đơn thuốc điện tử chính xác và nhanh chóng
- Kết nối liền mạch giữa bác sĩ và bệnh nhân
- Nâng cao trải nghiệm chăm sóc sức khỏe

---

## 🏗️ *Kiến trúc hệ thống*

┌─────────────────────────────────────────────────┐
│          Gluco Track Backend (NestJS)           │
│                 + Database                       │
└─────────────────┬───────────────────────────────┘
                  │
        ┌─────────┴─────────┐
        │                   │
┌───────▼────────┐  ┌──────▼────────┐
│ Gluco Track    │  │ Gluco Track   │
│    Doctor      │  │     User      │
│ (Flutter App)  │  │ (Flutter App) │
│  Dành cho      │  │  Dành cho     │
│   Bác sĩ       │  │  Bệnh nhân    │
└────────────────┘  └───────────────┘

---

## 🧩 *Tính năng theo từng ứng dụng*

## 👨‍⚕️ *Gluco Track Doctor - Ứng dụng Bác sĩ*

### ✅ *1. Hệ thống đăng nhập & xác thực*
- Đăng nhập bảo mật cho bác sĩ
- Đăng nhập bằng email
- Xác thực JWT Token

### 📅 *2. Quản lý lịch hẹn với bệnh nhân*
- *Dashboard tổng quan*: Xem tất cả lịch hẹn trong ngày/tuần/tháng
- *Lịch hẹn real-time*: Cập nhật trạng thái tức thì
- *Quản lý khung giờ*: Thiết lập thời gian khám bệnh
- *Xác nhận/Từ chối*: Duyệt yêu cầu đặt lịch từ bệnh nhân
- *Hủy/Dời lịch*: Thay đổi lịch hẹn linh hoạt
- *Lọc và tìm kiếm*: Theo trạng thái, ngày, bệnh nhân
- *Ghi chú*: Thêm ghi chú quan trọng cho từng cuộc hẹn
- *Thống kê*: Báo cáo số lượng bệnh nhân

### 💊 *3. Kê đơn thuốc điện tử*
- *Kê đơn nhanh*: Giao diện đơn giản, dễ sử dụng
- *Thư viện thuốc*: Tra cứu theo tên, hoạt chất
- *Thông tin chi tiết*: Liều lượng, cách dùng, số lượng
- *Lưu đơn mẫu*: Template đơn thuốc thường dùng
- *Chỉnh sửa*: Sửa đổi đơn trước khi gửi
- *Lịch sử*: Xem lại đơn đã kê

### 📋 *4. Quản lý hồ sơ bệnh nhân*
- *Danh sách bệnh nhân*: Xem tất cả bệnh nhân đã khám
- *Thông tin chi tiết*: Tiểu sử bệnh, tiền sử, dị ứng
- *Hồ sơ khám*: Ghi chú chẩn đoán, kết quả xét nghiệm
- *Tệp đính kèm*: Hình ảnh, tài liệu y tế
- *Lịch sử khám*: Theo dõi quá trình điều trị
- *Tìm kiếm*: Tra cứu nhanh theo tên, SĐT

### 📊 *5. Dashboard & Thống kê*
- *Tổng quan hôm nay*: Số lịch hẹn, bệnh nhân mới, lịch hủy
- *Biểu đồ*: Số lượng bệnh nhân theo thời gian
- *Báo cáo doanh thu*: Thống kê thu nhập
- *Hiệu suất*: Đánh giá năng suất khám bệnh

### 🔔 *6. Thông báo & Hỗ trợ*
- *Thông báo*: Lịch hẹn mới
- *Hỗ trợ kỹ thuật*: Liên hệ 24/7
- *Hướng dẫn*: Tài liệu, video tutorial
- *FAQ*: Câu hỏi thường gặp

---

## 👥 *Gluco Track User - Ứng dụng Bệnh nhân*

### ✅ *1. Hệ thống đăng nhập & xác thực*
- Đăng nhập bằng số điện thoại
- Xác thực OTP
- JWT Token

### 📅 *2. Đặt lịch hẹn với bác sĩ*
- *Tìm kiếm bác sĩ*: Theo chuyên khoa, phòng khám, đánh giá
- *Xem lịch khả dụng*: Hiển thị khung giờ trống
- *Đặt lịch nhanh*: Chọn ngày giờ và xác nhận
- *Quản lý lịch hẹn*: Xem, hủy, thay đổi
- *Check-in online*: Xác nhận đến khám

### 💊 *3. Quản lý đơn thuốc*
- *Danh sách đơn*: Xem tất cả đơn được kê
- *Chi tiết đơn*: Tên thuốc, liều lượng, cách dùng
- *Lịch sử*: Theo dõi theo thời gian
- *Tải xuống*: Lưu đơn dạng PDF

### 📋 *4. Tệp bệnh án điện tử*
- *Hồ sơ bệnh án*: Lưu trữ thông tin bệnh sử
- *Tải file*: Hình ảnh, tài liệu y tế

### 📊 *5. Chỉ số sức khỏe*
- *Theo dõi chỉ số*: Huyết áp, đường huyết, cân nặng
- *Biểu đồ*: Hiển thị xu hướng
- *Ghi chú*: Theo dõi triệu chứng hàng ngày
- *Mục tiêu*: Đặt và theo dõi mục tiêu cá nhân

### 👥 *6. Quản lý gia đình*
- *Thêm thành viên*: Quản lý nhiều hồ sơ
- *Đặt lịch cho người thân*: Đặt lịch cho gia đình
- *Hồ sơ độc lập*: Mỗi thành viên có bệnh án riêng

### 🏥 *7. Tìm kiếm phòng khám & bác sĩ*
- *Danh sách phòng khám*: Tìm theo vị trí, chuyên khoa
- *Thông tin chi tiết*: Địa chỉ, giờ làm việc, dịch vụ
- *Bác sĩ nổi bật*: Danh sách bác sĩ uy tín
- *Chuyên khoa đa dạng*: Đầy đủ các chuyên khoa

### 🔔 *8. Thông báo*
- *Thông báo ứng dụng*: Cập nhật trạng thái lịch hẹn

---

## ⚙️ *Stack công nghệ*

| Hạng mục | Công nghệ |
|----------|-----------|
| *Frontend* | Flutter, Dart |
| *State Management* | GetX |
| *Backend* | NestJS (Node.js) |
| *Authentication* | JWT Token, OTP |
| *Database* | PostgreSQL/MongoDB |
| *Storage* | Local Storage, Cloud Storage |
| *Platform* | Android, iOS |
| *Minimum Version* | Android 5.0+, iOS 12.0+ |

---

## 🚀 *Tính năng nổi bật*

### Cho Bác sĩ:
✅ Quản lý lịch hẹn thông minh với dashboard trực quan  
✅ Kê đơn điện tử nhanh chóng, chính xác  
✅ Hồ sơ bệnh nhân tập trung, dễ tra cứu  
✅ Thông báo real-time về lịch hẹn mới  
✅ Thống kê hiệu suất làm việc  

### Cho Bệnh nhân:
✅ Đặt lịch khám dễ dàng, nhanh chóng  
✅ Quản lý sức khỏe tập trung tại một nơi  
✅ Theo dõi chỉ số sức khỏe với biểu đồ trực quan  
✅ Quản lý cả gia đình trong một tài khoản  
✅ Giao diện thân thiện, dễ sử dụng  

### Chung:
✅ Bảo mật cao với mã hóa chuẩn quốc tế  
✅ Đa nền tảng (Android & iOS)  
✅ Đồng bộ real-time giữa doctor và user  
✅ Hỗ trợ 24/7  

---

## 📱 *Đối tượng sử dụng*

### Bác sĩ:
- Bác sĩ đa khoa
- Bác sĩ chuyên khoa
- Bác sĩ gia đình
- Bác sĩ tại phòng khám
- Bác sĩ tư vấn online

### Bệnh nhân:
- Người cần đặt lịch khám
- Người cao tuổi
- Phụ huynh (theo dõi con cái)
- Người bận rộn
- Bệnh nhân mãn tính

---

## 🔄 *Quy trình hoạt động*

### Phía Bệnh nhân:
1. Đăng ký/Đăng nhập tài khoản
2. Tìm kiếm bác sĩ phù hợp
3. Chọn khung giờ và đặt lịch
4. Nhận xác nhận từ bác sĩ
5. Check-in online trước khi khám
6. Nhận đơn thuốc điện tử sau khám
7. Theo dõi chỉ số sức khỏe

### Phía Bác sĩ:
1. Đăng nhập tài khoản
2. Xem dashboard và lịch hẹn
3. Xác nhận/Từ chối lịch hẹn
4. Xem hồ sơ bệnh nhân trước khám
5. Khám bệnh và ghi chú chẩn đoán
6. Kê đơn thuốc điện tử
7. Cập nhật hồ sơ bệnh án

---

## 🛠️ *Cài đặt và triển khai*

### Yêu cầu hệ thống:
- Android 5.0+ hoặc iOS 12.0+
- Kết nối internet ổn định
- Dung lượng: ~50MB cho mỗi app

### Hướng dẫn cài đặt:

#### Cho Bệnh nhân:
1. Tải Gluco Track User từ link download
2. Đăng ký bằng số điện thoại
3. Xác thực OTP
4. Hoàn tất hồ sơ cá nhân
5. Bắt đầu sử dụng

#### Cho Bác sĩ:
1. Tải Gluco Track Doctor từ link download
2. Đăng ký bằng email
3. Xác thực thông tin hành nghề
4. Thiết lập khung giờ làm việc
5. Bắt đầu nhận lịch hẹn

---

## 🔒 *Bảo mật & Quyền riêng tư*

- ✅ Tuân thủ các quy định bảo mật dữ liệu y tế
- ✅ Mã hóa end-to-end cho thông tin nhạy cảm
- ✅ Xác thực đa lớp (JWT + OTP)
- ✅ Quyền kiểm soát dữ liệu thuộc người dùng
- ✅ Không chia sẻ thông tin cho bên thứ ba
- ✅ Sao lưu dữ liệu định kỳ
- ✅ Log hoạt động để kiểm tra

## 📈 *Lợi ích khi sử dụng*

### Cho Bác sĩ:
✅ Tiết kiệm 40% thời gian hành chính  
✅ Tăng 30% số lượng bệnh nhân khám trong ngày  
✅ Giảm 90% sai sót trong kê đơn  
✅ Nâng cao hình ảnh chuyên nghiệp  
✅ Quản lý bệnh nhân hiệu quả hơn  

### Cho Bệnh nhân:
✅ Đặt lịch mọi lúc mọi nơi  
✅ Không cần gọi điện xếp hàng  
✅ Theo dõi sức khỏe khoa học  
✅ Lưu trữ hồ sơ y tế lâu dài  
✅ Quản lý cả gia đình dễ dàng  

---

## 📋 *Roadmap phát triển*

### ✅ Version 1.0 (Hiện tại):
- Quản lý lịch hẹn
- Kê đơn thuốc điện tử
- Quản lý hồ sơ bệnh nhân
- Theo dõi chỉ số sức khỏe
- Thông báo real-time

### 🔜 Version 2.0 (Q2/2025):
- Tích hợp video call khám từ xa
- Chat trực tiếp giữa bác sĩ - bệnh nhân
- Thanh toán online
- Đánh giá và nhận xét bác sĩ

### 🔜 Version 3.0 (Q4/2025):
- AI hỗ trợ chẩn đoán
- Tích hợp thiết bị đo y tế (IoT)
- Báo cáo thống kê nâng cao
- Đồng bộ với hệ thống bệnh viện
- Đa ngôn ngữ (English, 中文)

---
## 📄 *Giấy phép*

© 2025 Gluco Track. All rights reserved.

---

## 🌟 *Lời kết*

*Gluco Track* không chỉ là ứng dụng y tế, mà là cầu nối giữa bác sĩ và bệnh nhân, góp phần xây dựng hệ thống y tế thông minh, hiện đại và nhân văn.

🎯 *"Công nghệ kết nối - Sức khỏe trao tay - Tương lai y tế số"*

---

*Cảm ơn bạn đã quan tâm đến Gluco Track!* 🏥💙