import 'dart:io';
import 'dart:convert';
import 'dart:async';

class TemperatureServer {
  static const int PORT = 8080;
  late ServerSocket serverSocket;
  List<Socket> connectedClients = [];

  Future<void> startServer() async {
    try {
      print('🌡️  Iniciando Servidor de Temperatura na porta $PORT...');

      // Inicia servidor
      serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, PORT);
      print('✅ Servidor escutando em ${serverSocket.address.address}:$PORT');

      // Escuta conexões
      serverSocket.listen(
        (Socket client) {
          print('👤 Novo cliente conectado: ${client.remoteAddress.address}');
          connectedClients.add(client);

          // Escuta dados do cliente
          client.listen(
            handleData,
            onError: (error) {
              print('❌ Erro no cliente ${client.remoteAddress.address}: $error');
              client.destroy();
            },
            onDone: () {
              print('🔌 Cliente ${client.remoteAddress.address} desconectado');
              connectedClients.remove(client);
              client.destroy();
            },
          );
        },
        onError: (error) {
          print('❌ Erro no servidor: $error');
        },
      );

    } catch (e) {
      print('❌ Falha ao iniciar servidor: $e');
    }
  }

  void handleData(data) {
    String message = utf8.decode(data).trim();

    try {
      // Processa cada linha JSON recebida
      List<String> lines = message.split('\n');
      for (String line in lines) {
        if (line.isNotEmpty) {
          Map<String, dynamic> jsonData = jsonDecode(line);
          displayTemperatureData(jsonData);
        }
      }
    } catch (e) {
      print('❌ Erro ao processar dados: $e');
      print('📄 Dados brutos: $message');
    }
  }

  void displayTemperatureData(Map<String, dynamic> data) {
    double temp = data['temperature'];
    String timestamp = data['timestamp'];
    String deviceId = data['device_id'];
    String location = data['location'];

    // Formatação colorida no terminal
    String color = temp > 30 ? '\x1B[31m' : temp < 18 ? '\x1B[33m' : '\x1B[32m';
    String reset = '\x1B[0m';

    print('\n${color}'
          '🌡️  TEMPERATURA RECEBIDA 🌡️  '
          '${reset}');
    print('📍  Dispositivo: $deviceId');
    print('📍  Local: $location');
    print('${color}🌡️  Temperatura: ${temp}°C${reset}');
    print('⏰  Horário: ${DateTime.parse(timestamp).toLocal()}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}

void main() async {
  print('''

  🌡️🌡️🌡️  SERVIDOR IoT TEMPERATURA  🌡️🌡️🌡️
  Porta: ${TemperatureServer.PORT}
  Aguarde conexão do dispositivo IoT...

  ''');

  TemperatureServer server = TemperatureServer();
  await server.startServer();

  // Mantém servidor rodando indefinidamente
  await Future.delayed(Duration(days: 365));
}