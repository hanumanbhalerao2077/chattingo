package com.chattingo.Controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import com.chattingo.Model.Message;

@Controller
public class RealTimeChat {

    @Autowired
    private SimpMessagingTemplate simpMessagingTemplate;

    /**
     * Handles real-time message reception via WebSocket
     * Routes messages to the appropriate chat group
     * 
     * @param message The message payload from the client
     * @return The message object for confirmation
     */
    @MessageMapping("/message")
    public void receiveMessage(@Payload Message message) {
        if (message != null && message.getChat() != null && message.getChat().getId() != null) {
            String destination = message.getChat().isGroup() 
                ? "/group/" + message.getChat().getId() 
                : "/user/" + message.getChat().getId();
            simpMessagingTemplate.convertAndSend(destination, message);
        }
    }

}
