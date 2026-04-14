import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:async';

class IoTSensor {
  static const String SERVER_HOST = '127.0.0.1';
  static const int SERVER_PORT = 8080;
  late Socket socket;
  late Timer timer;
  Random random = Random();

  Future<void> connectAndSend() async {
    try {
      print('🔥 IoT Sensor iniciando conexão com servidor $SERVER_HOST:$SERVER_PORT...');

      // Conecta ao servidor
      socket = await Socket.connect(SERVER_HOST, SERVER_PORT);
      print('✅ Conectado ao servidor!');

      // Inicia envio periódico de dados a cada 10 segundos
      timer = Timer.periodic(Duration(seconds: 10), (timer) {
        sendTemperatureData();
      });

      // Envia primeira leitura imediatamente
      sendTemperatureData();

    } catch (e) {
      print('❌ Erro ao conectar: $e');
      await Future.delayed(Duration(seconds: 5));
      connectAndSend(); // Tenta reconectar
    }
  }

  void sendTemperatureData() {
    // Simula temperatura realista (15-35°C)
    double temperature = 25.0 + (random.nextDouble() - 0.5) * 20;
    temperature = double.parse(temperature.toStringAsFixed(2));

    // Cria payload JSON
    Map<String, dynamic> data = {
      'timestamp': DateTime.now().toIso8601String(),
      'device_id': 'sensor_temp_001',
      'temperature': temperature,
      'unit': '°C',
      'location': 'Sala de Controle'
    };

    String jsonData = jsonEncode(data);

    try {
      // Envia dados pelo socket
      socket.write('$jsonData\n');
      print('📤 Enviado: ${data['temperature']}°C às ${data['timestamp']}');
    } catch (e) {
      print('❌ Erro ao enviar dados: $e');
      timer.cancel();
      socket.destroy();
      connectAndSend(); // Reconecta
    }
  }

  void dispose() {
    timer.cancel();
    socket.destroy();
  }
}

void main() async {
  print('🚀 Iniciando Dispositivo IoT Sensor de Temperatura...\n');

  IoTSensor sensor = IoTSensor();

  sensor.connectAndSend();
}