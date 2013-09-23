/*
	THIS CLASS is for handling Customer Complaint Emails that have a specific form that is filled & possibly some Attachments.
	
	ATTACHMENT sizes could vary from 5-10mb per file MAXIMUM, there can be a TOTAL of 6 of those files.
	BUT: Single attachment limit is 5 MB. Total size limit for email content and all files attached to an email is about 7MB 
	
	This DATA will be processed into a NEW CASE in Salesforce
*/

global class emailCaseHandler implements Messaging.InboundEmailHandler {
	//Implements the Messaging.InboundEmailHandler by using this method
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
		
		/*
		Information about the InboundEmail Object:
		http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_classes_email_inbound_inbound.htm
		*/
		
		//Now all the logic...
		String emailBody = '';
		String emailSubject = '';
		String emailSender = '';
		String emailSenderName = '';
		
		Boolean errorFree = false;
		Case c = new Case(Status = 'Open');
		List<Attachment> attachments = new List<Attachment>();
		
		try{
			//Get the basic email information and add it to a new Case
			emailSender = email.fromAddress;
			emailSenderName = email.fromName;
			emailSubject = email.Subject;
			c.Subject = emailSubject;
			
			emailBody = email.plainTextBody;
			c.Description = emailBody;
			
			//Get the possible attachments from the email, set them to this case
			if(email.binaryAttachments != null && email.binaryAttachments.size() > 0){
				//found some attachments, Yey!
				for(Messaging.InboundEmail.Binaryattachment ba : email.binaryAttachments){
					Attachment a = new Attachment(Name = ba.filename, Body = ba.Body);
					attachments.add(a);
				}
			}
			errorFree = true;
		}catch(Exception e){
			System.debug('Email Handling: Something went wrong while processing the email');
			errorFree = false;
		}
		
		
		//Try Inserting the Case & The attachments if parsing the email was successful
		if(errorFree){
			Boolean caseInsertOK = false;
			
			//Insert Case
			try{
				insert c;
				caseInsertOK = true;
			}catch(Exception e){System.debug('Email Handling: Could not insert the Case');}
			
			//Insert Attachments [IF case has been inserted]
			if(caseInsertOK){
				try{
					for(Attachment a : attachments) a.ParentId = c.Id;
					insert attachments;
				}catch(Exception e){
					System.debug('Email Handling: Could not insert attachments, gonna delete the case');
					delete c;
				}
			}
		}
		else{
			//IF there were errors while parsing the email, there could be some logic to do something in here
			System.debug('Email Handling: I Refused to work with this email!');
		}
		
		//This is the end
		return result;
	}
}