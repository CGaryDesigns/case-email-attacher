/**
 * This class is designed to be an extension to the CaseEmailAttachmentsAction 
 * custom publisher action. For the most part, it is here in order to provide
 * RemoteAction methods to the Angular Application on the page.
 *
 * @author Cloud Performer <cgary@cloudperformer.com>
 * @version 1.0
 **/ 
global with sharing class CaseEmailAttachmentsActionExt {
    /**
     * Constructor
     **/
    public CaseEmailAttachmentsActionExt() {

    }
    /**
     * Constructor
     **/
    public CaseEmailAttachmentsActionExt(ApexPages.StandardController stdCon){

    }
    /**
     * the purpose of this method is to provide a list of Email Template Folders
     * that a person can choose a case Email Template from
     *
     * @return Map<String,String> a map of Folders and the Corresponding Ids
     **/
    @RemoteAction
    global static Map<String,String> ObtainEmailTemplateFolders(){
        //get the folders
        List<Folder> folderList = [SELECT Id, DeveloperName, Name, Type FROM Folder WHERE Type='Email'];
        Map<String,String> returnMap = new Map<String,String>();
        for(Folder f:folderList){
            returnMap.put(f.Name,f.Id);
        }
        return returnMap;
    }
    /**
     * the purpose of this method is to provide a list of email templates
     * based on a FolderId that is passed in.
     *
     * @param String folderId                       - the FolderId to look up
     * @return Map<String,String>                   - a Map of Template Names to TemplateIds.
     **/
    @RemoteAction
    global static Map<String,String> ObtainEmailTemplates(String folderId){
        List<EmailTemplate> templateList = [SELECT Id, Name FROM EmailTemplate WHERE FolderId =:folderId];
        Map<String,String> returnMap = new Map<String,String>();
        for(EmailTemplate et:templateList){
            returnMap.put(et.Name, et.Id);
        }
        return returnMap;
    }
    /**
     * this method is designed to provide the compiled body of an Email Template
     * based on the template Id passed in, the Case Id and the Contact Id Passed in
     *
     * @param String templateId                     - the template Id to pass in
     * @param String caseId                         - the case Id to use
     * @param String contactId                      - the Contact Id to use to 
     * @return String emailbody                     - the email body to use
     **/
    @RemoteAction
    global static String GetCompiledEmailBody(String templateId, String caseId, String contactId){
        Messaging.SingleEmailMessage mess = Messaging.renderStoredEmailTemplate(templateId, contactId, caseId);
        return JSON.serialize(mess);
    }
    /**
     * this method is responsible for getting the list of file attachments to the case
     *
     * @param String caseId                     - the Case Id to look for related attachments to.
     * @return Map<String,String>               - a map of file name to contentIds.
     **/
    @RemoteAction
    global static Map<String,String> GetCaseAttachments(String caseId){
        Map<String,String> returnMap = new Map<String,String>();
        List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :caseId];
        for(ContentDocumentLink cdl:cdlList){
            returnMap.put(cdl.ContentDocumentId,cdl.ContentDocument.Title);
        }
        return returnMap;
    }

    /**
     * @description - responsible for sending email with attachments
     * @param String templateId                     - the id of the template ot use
     * @param String caseId                         - the id of the case
     * @param String contactId                      - the id of the contact
     * @param List<String> contentIds               - a list of content Ids as attachments
     **/
    @RemoteAction
    global static void SendEmail(String templateId, String caseId, String contactId, List<String> contentIds){
        //get the content version IDs of the content documents
        Set<Id> contentIdSet = new Set<Id>();
        contentIdSet.addAll(contentIds);
        List<ContentDocument> cdList = [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE Id IN :contentIdSet];
        Set<Id> contentVersionIdSet = new Set<Id>();
        for(ContentDocument cd:cdList){
            contentVersionIdSet.add(cd.LatestPublishedVersionId);
        }
        List<String> contentVersionIdList = new List<String>();
        for(String contentVersionId:contentVersionIdSet){
            contentVersionIdList.add(contentVersionId);
        }
        //contentVersionIdList.addAll(contentVersionIdSet);
        Messaging.SingleEmailMessage mess = Messaging.renderStoredEmailTemplate(templateId, contactId, caseId);
        mess.setEntityAttachments(contentVersionIdList);
        mess.setSaveAsActivity(true);
        List<Messaging.SendEmailResult> resList = Messaging.sendEmail(new Messaging.Email[]{mess});

    }
}
