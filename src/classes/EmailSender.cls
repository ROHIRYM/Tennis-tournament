public class EmailSender {
    
    public static EmailSender EMAIL_SENDER = new EmailSender();
    
    private EmailSender() {
    	
    }
    
    public void sendLetter(Integer singleEmailCapacity, String[] toAddresses,
    		String senderDisplayName, String subject, String plainTextBody, String htmlBody){
        Messaging.reserveSingleEmailCapacity(singleEmailCapacity);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] ccAddresses = new String[] {'rohirym@techmagic.co'};
        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        // Specify the name used as the display name.
        mail.setSenderDisplayName(senderDisplayName);
        // Specify the subject line for your email address.
        mail.setSubject(subject);
        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);
        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);
        // Specify the text content of the email.
        mail.setPlainTextBody(plainTextBody);
        mail.setHtmlBody(htmlBody);
        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}