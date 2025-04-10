// Bảng lưu thông tin người dùng
Table User {
    _id ObjectId
    name string
    email string [unique]
    password_hash string
    avatar_url string
    role enum("user", "admin")
    created_at datetime
    updated_at datetime
}

// Bảng theo dõi tiến trình học của người dùng
Table UserProgress {
    _id ObjectId
    user_id ObjectId [ref: > User._id]
    total_study_time int // Tổng thời gian học (phút)
    streak_days int // Số ngày streak
    last_active datetime
}

// Bảng chủ đề luyện tập
Table Topic {
    _id ObjectId
    name string
    description string
    level enum("beginner", "intermediate", "advanced")
    created_at datetime
}

// Bảng chứa danh sách bài tập theo từng chủ đề
Table Exercise {
    _id ObjectId
    topic_id ObjectId [ref: > Topic._id]
    type enum("multiple_choice", "pronunciation", "speaking")
    question string
    correct_answer string // Dùng cho bài trắc nghiệm hoặc bài nói có câu trả lời chuẩn
    options JSON // Danh sách đáp án cho bài trắc nghiệm
    IPA string // Phiên âm dùng cho phần nói 
    translation string // Bản dịch anh -> việt , hoặc việt -> anh cho phần nói
    reference_audio_url string // Âm thanh mẫu cho bài phát âm hoặc nói
    created_at datetime
}

// Bảng lưu kết quả làm bài tập của người dùng
Table UserExercise {
    _id ObjectId
    user_id ObjectId [ref: > User._id]
    exercise_id ObjectId [ref: > Exercise._id]
    user_answer string // Cho bài trắc nghiệm hoặc bài nói (nếu không có audio)
    audio_url string // Cho bài nói hoặc phát âm
    transcription string // Bản ghi âm thanh của người dùng
    is_correct boolean // Cho bài trắc nghiệm
    score float // Điểm cho bài nói hoặc phát âm
    feedback JSON // Phản hồi chi tiết (ví dụ: { pronunciation: { score: 85, details: "..." }, grammar: [{ mistake: "go", suggestion: "went" }] })
    created_at datetime
}

// Bảng chứa lịch sử hội thoại giữa người dùng và AI
Table Conversation {
    _id ObjectId
    user_id ObjectId [ref: > User._id]
    topic string
    ai_assistant string // AI nào đang hỗ trợ (nếu có nhiều mô hình)
    situation_description string // Mô tả tình huống đã được xử lý
    created_at datetime
    score float // Điểm đánh giá tổng thể cuộc hội thoại
}

// Bảng chứa tin nhắn trong mỗi cuộc hội thoại
Table Message {
    _id ObjectId
    conversation_id ObjectId [ref: > Conversation._id]
    role enum("user", "ai")
    text string // Nội dung tin nhắn (đối với người dùng là bản ghi âm thanh)
    audio_url string // URL của file âm thanh (nếu có)
    feedback JSON // Phản hồi chi tiết (ví dụ: { grammar: [{ mistake: "go", suggestion: "went" }], vocabulary: [{ word: "good", alternative: "excellent" }], pronunciation: { score: 85, details: "..." } })
    created_at datetime
}

// Bảng chứa hình ảnh để mô tả
Table Image {
    _id ObjectId
    url string // URL của hình ảnh
    reference_description string // Mô tả tham chiếu cho hình ảnh
    key_points JSON // Các điểm chính cần mô tả (ví dụ: ["modern office", "glass walls"])
    created_at datetime
}

// Bảng lưu dữ liệu mô tả hình ảnh của người dùng
Table ImageDescription {
    _id ObjectId
    user_id ObjectId [ref: > User._id]
    image_id ObjectId [ref: > Image._id]
    description_text string // Mô tả của người dùng
    audio_url string // audio của người dùng
    transcription string // Bản ghi âm thanh (nếu có)
    score float // Điểm theo tiêu chí TOEIC
    feedback JSON // Phản hồi chi tiết (grammar, vocabulary, etc.)
    created_at datetime
}

// Bảng chọn chủ đề có sẵn để luyện tập (nếu cần)
Table PracticeTopic {
    _id ObjectId
    topic_id ObjectId [ref: > Topic._id]
    recommended_sentences JSON // Danh sách câu gợi ý cho chủ đề
    created_at datetime
}

// Bảng theo dõi hoạt động hằng ngày của người dùng
Table StreakTracking {
    _id ObjectId
    user_id ObjectId [ref: > User._id]
    date date
    study_time int // Số phút học trong ngày
    speaking_attempts int // Số lần bấm micro
}