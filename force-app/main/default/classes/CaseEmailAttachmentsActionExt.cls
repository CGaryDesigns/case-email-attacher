/**
 * This class is designed to be an extension to the CaseEmailAttachmentsAction 
 * custom publisher action. For the most part, it is here in order to provide
 * RemoteAction methods to the Angular Application on the page.
 *
 * @author Cloud Performer <cgary@cloudperformer.com>
 * @version 1.0
 **/ 
public with sharing class CaseEmailAttachmentsActionExt {
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
    public static Map<String,String> ObtainEmailTemplateFolders(){
        //get the folders
        List<Folder> folderList = [SELECT Id, DeveloperName, Name, Type FROM Folder WHERE Type='Email'];
        Map<String,String> returnMap = new Map<String,String>();
        for(Folder f:folderList){
            returnMap.put(f.Name,f.Id);
        }
        return returnMap;
    }
}
