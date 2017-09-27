import java.io.File;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.file.Files;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;

@ServerEndpoint("/DataPointServer/{connectionID}")
//NSUrlDownloadSession from obj-c can possibly connect to /DataPointServer/{fileName} to download a file
//Thus, maybe I can still use the download progress bar
public class DataPointServer {

	static String vizardConnectionID;
	static String iPadConnectionID;
	
	private static Set<Session> clients = Collections.synchronizedSet(new HashSet<Session>());
	
	@OnOpen
	public void onOpen(@PathParam("connectionID") String connectionID, Session session){
		if (connectionID.equals("0")){
			System.out.println("vizard");
			vizardConnectionID = session.getId();
			clients.add(session);
			System.out.println("Original vizard ID = " + vizardConnectionID);
		} else if (connectionID.equals("1")){
			System.out.println("ipad");
			iPadConnectionID = session.getId();
			clients.add(session);
			System.out.println("Original iPad ID = " + iPadConnectionID);
		} else if (connectionID.equals("2")){
			//Used to give iPad names of available computer resources
			System.out.println("ipad resource table");
			iPadConnectionID = session.getId();
			clients.add(session);
			System.out.println("Original iPad Resource Table ID = " + iPadConnectionID);			
		} else{
			System.out.println("File request");
		}
	}
	
	@OnMessage
	public void onMessage(String message, Session session){
		/*for (Session s : session.getOpenSessions()){
			if (s.isOpen() && s.getId().equals(vizardConnectionID)){
				try{
					System.out.println(message);
					s.getBasicRemote().sendText(message);
				} catch (IOException ex){
					ex.printStackTrace();
				}
			}
		}*/
		System.out.println(message);
		if(message.equals("td")){
			
			File resourceDirectory = new File("C:/Users/Willem Beeson/Desktop/VizardClient-master/resource");
			File[] listOfResources = resourceDirectory.listFiles();
			String[] namesOfResources = new String[listOfResources.length];
			
			for(int i=0; i<listOfResources.length; i++)
				if(listOfResources[i].isFile())
					namesOfResources[i] = listOfResources[i].getName();
			
			if(session.getId().equals(iPadConnectionID)){
				try {
					for(int i=0; i<namesOfResources.length; i++)
						session.getBasicRemote().sendText(namesOfResources[i]);
					session.getBasicRemote().sendText("done");
					} catch (IOException ex) {
						ex.printStackTrace();
					}
			}
		}
		else if(message.substring(0, 1).equals("d")){
			
			File imageToSend = new File("C:/Users/Willem Beeson/Desktop/VizardClient-master/resource/" + message.substring(2, message.length()));
			byte[] imageFile = null, bytesToSend = null, intermediateBytesForImageFile = null;
			boolean isLast = false;
			
			try{
				imageFile = Files.readAllBytes(imageToSend.toPath());
				
				while(!isLast){
					if(imageFile.length<1000000){
						isLast = true;
						bytesToSend = imageFile;
					}else{
						bytesToSend = Arrays.copyOfRange(imageFile, 0, 1000000);
						intermediateBytesForImageFile = new byte[imageFile.length-1000000];
						
						for(int i = 1000000; i<imageFile.length; i++)
							intermediateBytesForImageFile[i-1000000] = imageFile[i];
						imageFile = intermediateBytesForImageFile;
					}
					ByteBuffer byteBuf = ByteBuffer.wrap(bytesToSend);
					session.getBasicRemote().sendBinary(byteBuf, isLast);
				}
				//ByteBuffer byteBuf = ByteBuffer.wrap(imageFile);
				//session.getBasicRemote().sendBinary(byteBuf);
			}catch(IOException e){
				e.printStackTrace();
			}
		}
		else{
			synchronized(clients){
				// Iterate over the connected sessions
				// and broadcast the received message
				for(Session client : clients){
					if (!client.equals(session)){
						try {
							client.getBasicRemote().sendText(message);
							System.out.println(message);
						} catch (IOException ex) {
							ex.printStackTrace();
						}
					}
				}
			}
        }
	}
	
	@OnClose 
	public void onClose(Session session) throws IOException{
		System.out.println("Session " + session.getId() + " has ended");
		clients.remove(session);
		session.close();		
	}
	
}
