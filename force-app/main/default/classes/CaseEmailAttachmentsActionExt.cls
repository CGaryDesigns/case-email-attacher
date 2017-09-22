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
    @RemotAction
    global static String GetCompiledEmailBody(String templateId, String caseId, String contactId){
        Messaging.SingleEmailMessage mess = Messaging.renderStoredEmailTemplate(templateId, contactId, caseId);
        return JSON.serialize(mess);
    }
}
