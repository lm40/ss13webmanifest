package net.chompstation13.manifest;

import java.io.DataInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.Socket;

import org.springframework.stereotype.Component;
import org.springframework.web.context.annotation.RequestScope;

@Component
@RequestScope
@ConfigurationProperties(prefix = "socket.manifest")
public class SocketComponent {
	private Socket socket;
	private String host;
	private int port;

	private boolean isConnected() {
		if (socket == null) return false;
		if (socket.isClosed()) return false;
		return socket.isConnected();
	}
	
	private void open() throws IOException {
		if (isConnected()) return;
		socket = new Socket(host, port);
	}
	
	public String send(byte[] message) throws IOException {
		try {
			open();
			return sendWithError(message);
		} catch (IOException e) {
			e.printStackTrace();
			socket.close();
			throw e;
		}
	}
	
	private String sendWithError(byte[] message) throws IOException {
		OutputStream dOut = socket.getOutputStream();
		dOut.write(message);
		DataInputStream dIn = new DataInputStream(socket.getInputStream());
		dIn.readByte(); //always 0x00
		dIn.readByte(); //always 0x83
		short length = dIn.readShort();
		if (length <= 0) return "";
		
		byte type = dIn.readByte(); //should be 0x06
//		if (type != 0x06) throw new IOException("Unknown return type");
		
		StringBuilder iMessage = new StringBuilder();
		byte b;
		do {
			b = dIn.readByte();
			if (b == 0x00) {
				break;
			} else {
				iMessage.append((char) b);
			}
		} while (true);
		
		return iMessage.toString();
	}
	
	public void destroy() throws IOException {
		if (socket != null) socket.close();
	}
}
