# Cấu Trúc Thư Mục Tính Năng Trang Chủ

Thư mục này chứa phần triển khai tính năng trang chủ trong ứng dụng học tiếng Anh của chúng ta. Tính năng trang chủ đóng vai trò là điểm vào chính và bảng điều khiển cho người dùng, cung cấp quyền truy cập vào các hoạt động học tập khác nhau và hiển thị thông tin tiến độ.

## Cấu Trúc Thư Mục

### 1. `data/`
Thư mục này xử lý các hoạt động liên quan đến dữ liệu cho tính năng trang chủ.

- **models/**: Chứa các mô hình dữ liệu đại diện cho các dữ liệu có cấu trúc từ các nguồn bên ngoài (API, cơ sở dữ liệu).
- **repositories/**: Triển khai các giao diện repository được định nghĩa trong lớp domain.
  - `home_repository_impl.dart`: Triển khai cụ thể của repository trang chủ, có nhiệm vụ lấy và quản lý dữ liệu liên quan đến trang chủ.

### 2. `di/` (Dependency Injection)
Quản lý các phụ thuộc cho tính năng trang chủ.

- `home_module.dart`: Cấu hình và cung cấp các phụ thuộc cần thiết cho tính năng trang chủ (repositories, use cases, controllers).

### 3. `domain/`
Chứa logic và quy tắc nghiệp vụ cốt lõi cho tính năng trang chủ.

- **entities/**: Các đối tượng nghiệp vụ đại diện cho các cấu trúc dữ liệu cốt lõi.
  - `home_type.dart`: Định nghĩa các loại nội dung khác nhau được hiển thị trên màn hình trang chủ.
  - `user.dart`: Đại diện cho thực thể người dùng với thông tin hồ sơ.
- **repositories/**: Định nghĩa các giao diện trừu tượng cho các hoạt động dữ liệu.
  - `home_repository.dart`: Định nghĩa trừu tượng các phương thức truy cập dữ liệu liên quan đến trang chủ.
- **usecases/**: Triển khai các hoạt động logic nghiệp vụ cụ thể.
  - `get_home_types.dart`: Logic nghiệp vụ để lấy các loại nội dung khác nhau trên màn hình trang chủ.

### 4. `presentation/`
Quản lý giao diện người dùng và các khía cạnh tương tác người dùng của tính năng trang chủ.

- **bloc/**: Chứa BLoC (Business Logic Component) để quản lý trạng thái người dùng.
  - `user_bloc.dart`: Quản lý trạng thái và sự kiện liên quan đến người dùng.
- **cubit/**: Chứa các thành phần Cubit cho việc quản lý trạng thái đơn giản hơn.
  - `home_cubit.dart`: Quản lý trạng thái màn hình trang chủ.
  - `home_state.dart`: Định nghĩa các trạng thái có thể có của màn hình trang chủ.
- **pages/**: Các thành phần trang cấp cao.
  - `home_page.dart`: Container của trang chính trang chủ.
- **screens/**: Các thành phần màn hình thường sử dụng nhiều widget.
  - `home_screen.dart`: Màn hình chính được hiển thị cho người dùng sau khi đăng nhập.
- **utils/**: Các lớp tiện ích cho lớp trình bày.
  - `app_colors.dart`: Định nghĩa màu sắc cho sự đồng nhất của giao diện người dùng.
  - `responsive_layout.dart`: Tiện ích cho thiết kế đáp ứng.
- **widgets/**: Các thành phần giao diện người dùng có thể tái sử dụng cụ thể cho tính năng trang chủ.
  - **components/**: Các thành phần widget chuyên biệt.
    - **app_bar/**: Các thành phần app bar tùy chỉnh.
    - **cards/**: Các widget thẻ hiển thị trên màn hình trang chủ.
    - **sections/**: Các phần được tổ chức trên màn hình trang chủ.
  - `home_card.dart`: Widget thẻ cơ bản được sử dụng trên toàn màn hình trang chủ.
  - `home_content.dart`: Container nội dung chính cho màn hình trang chủ.
  - `user_profile_card.dart`: Widget hiển thị thông tin hồ sơ người dùng.

## Cách Các Thành Phần Hoạt Động Cùng Nhau

Tính năng trang chủ tuân theo các nguyên lý kiến trúc sạch với sự phân tách rõ ràng các mối quan tâm:

1. **Lớp domain** định nghĩa tính năng nên làm gì thông qua các thực thể, giao diện repository và use case.
2. **Lớp data** triển khai các repository để lấy và quản lý dữ liệu từ các nguồn bên ngoài.
3. **Lớp di** kết nối các phụ thuộc giữa các lớp khác nhau.
4. **Lớp presentation** xử lý việc render giao diện người dùng và các tương tác người dùng, sử dụng quản lý trạng thái (Bloc/Cubit) để phản hồi các hành động của người dùng và hiển thị giao diện người dùng phù hợp với trạng thái hiện tại.

