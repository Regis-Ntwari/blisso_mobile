import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/services/models/chat_message_model.dart';

class ChatService {
  Future<ApiResponse> sendMessage(ChatMessageModel message) async {
    return await ApiService().getData('endpoint', 'token');
  }

  ApiResponse getMessages(String username) {
    return ApiResponse.success(result: [
      {
        "williamspeterson@gmail.com": [
          {
            "message_id": "678cea3e7a58801069a29ead",
            "content": "He Williams",
            "content_file_url": "",
            "content_file_type": "",
            "sender": "niyibizischadrack@gmail.com",
            "receiver": "williamspeterson@gmail.com",
            "sender_receiver":
                "niyibizischadrack@gmail.com_williamspeterson@gmail.com",
            "created_at": "2025-01-19T12:04:14.345Z",
            "is_file_included": false
          },
          {
            "message_id": "678cea4c7a58801069a29eae",
            "content": "Hey Schadrack",
            "content_file_url": "",
            "content_file_type": "",
            "sender": "williamspeterson@gmail.com",
            "receiver": "niyibizischadrack@gmail.com",
            "sender_receiver":
                "williamspeterson@gmail.com_niyibizischadrack@gmail.com",
            "created_at": "2025-01-19T12:04:28.825Z",
            "is_file_included": false
          },
          {
            "message_id": "678ceb197a58801069a29eb0",
            "content": "Can you check this picture?",
            "content_file_url": "",
            "content_file_type": "",
            "sender": "niyibizischadrack@gmail.com",
            "receiver": "williamspeterson@gmail.com",
            "sender_receiver":
                "niyibizischadrack@gmail.com_williamspeterson@gmail.com",
            "created_at": "2025-01-19T12:07:53.754Z",
            "is_file_included": false
          },
          {
            "message_id": "678cef32ec242f7880e66ca6",
            "content": "Hey there",
            "content_file_url": "",
            "content_file_type": "",
            "sender": "niyibizischadrack@gmail.com",
            "receiver": "williamspeterson@gmail.com",
            "sender_receiver":
                "niyibizischadrack@gmail.com_williamspeterson@gmail.com",
            "created_at": "2025-01-19T12:25:22.002Z",
            "is_file_included": false
          },
          {
            "message_id": "678cfcd6ca6307dcb75847bf",
            "content": "",
            "content_file_url":
                "https://blissostorage.blob.core.windows.net/blissochat/1737292998739837900.image/jpeg",
            "content_file_type": "image/jpeg",
            "sender": "niyibizischadrack@gmail.com",
            "receiver": "williamspeterson@gmail.com",
            "sender_receiver":
                "niyibizischadrack@gmail.com_williamspeterson@gmail.com",
            "created_at": "2025-01-19T13:23:17.559Z",
            "is_file_included": true
          },
          {
            "message_id": "678d0349a41a7f6e6890875c",
            "content": "",
            "content_file_url":
                "https://blissostorage.blob.core.windows.net/blissochat/1737294650888641800.jpeg",
            "content_file_type": "image/jpeg",
            "sender": "niyibizischadrack@gmail.com",
            "receiver": "williamspeterson@gmail.com",
            "sender_receiver":
                "niyibizischadrack@gmail.com_williamspeterson@gmail.com",
            "created_at": "2025-01-19T13:50:49.589Z",
            "is_file_included": true
          },
          {
            "message_id": "678d041ca41a7f6e6890875d",
            "content": "",
            "content_file_url":
                "https://blissostorage.blob.core.windows.net/blissochat/1737294864388766900.png",
            "content_file_type": "image/png",
            "sender": "niyibizischadrack@gmail.com",
            "receiver": "williamspeterson@gmail.com",
            "sender_receiver":
                "niyibizischadrack@gmail.com_williamspeterson@gmail.com",
            "created_at": "2025-01-19T13:54:23.405Z",
            "is_file_included": true
          },
          {
            "message_id": "678d0446a41a7f6e6890875e",
            "content": "",
            "content_file_url":
                "https://blissostorage.blob.core.windows.net/blissochat/1737294911155162600.mp4",
            "content_file_type": "video/mp4",
            "sender": "williamspeterson@gmail.com",
            "receiver": "niyibizischadrack@gmail.com",
            "sender_receiver":
                "williamspeterson@gmail.com_niyibizischadrack@gmail.com",
            "created_at": "2025-01-19T13:55:10.261Z",
            "is_file_included": true
          }
        ]
      },
      {
        "nishimwegeorges@gmail.com": [
          {
            "message_id": "678ceaea7a58801069a29eaf",
            "content": "Hey Schadrack",
            "content_file_url": "",
            "content_file_type": "",
            "sender": "nishimwegeorges@gmail.com",
            "receiver": "niyibizischadrack@gmail.com",
            "sender_receiver":
                "nishimwegeorges@gmail.com_niyibizischadrack@gmail.com",
            "created_at": "2025-01-19T12:07:06.088Z",
            "is_file_included": false
          },
          {
            "message_id": "678ced65d6fdd0e87f2089fd",
            "content": "Hey Geroges",
            "content_file_url": "",
            "content_file_type": "",
            "sender": "niyibizischadrack@gmail.com",
            "receiver": "nishimwegeorges@gmail.com",
            "sender_receiver":
                "niyibizischadrack@gmail.com_nishimwegeorges@gmail.com",
            "created_at": "2025-01-19T12:17:41.954Z",
            "is_file_included": false
          }
        ]
      }
    ], statusCode: 201);
  }
}
