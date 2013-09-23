//THIS is a test comment to see if this works on GIT!
//What happened?
//Did it work?
public class DrinksCalculatorController{
	//Private
	private String currentUserId;
    private List<Consumed_Drink__c> consumedDrinks {get;set;}
    //Public
    public String currentUserFirstName {get;set;}
    public List<Drink__c> products {get;set;}
    public List<String> drinkers {get;set;}
    public Map<String, List<Consumed_Drink__c>> whoDrankWhat {get;set;} //Username, consumedDrinks
    public String clickedProduct {get;set;}
    
    
    public DrinksCalculatorController(){
    	currentUserId = Userinfo.getUserId();
    	currentUserFirstName = Userinfo.getFirstName();
    	clickedProduct = '';
        products = [SELECT Name FROM Drink__c];
        consumedDrinks = [SELECT Id FROM Consumed_Drink__c ORDER BY Consumer_Name__c DESC];
        
        //Drinks consumed by Drinkers
        whoDrankWhat = new Map<String, List<Consumed_Drink__c>>();
        drinkers = new List<String>();
        Integer tempInt = 0;
        Integer endIsNear = 1;
        List<Consumed_Drink__c> tempDrinks = new List<Consumed_Drink__c>();
        
        //Add Drink to tempList, cleared when drinker changes, previous list to map.
        for(Consumed_Drink__c cd : consumedDrinks){
        	tempDrinks.add(cd);
        	//Drinker changes
        	if(drinkers[tempInt] != cd.Consumer_Name__c){
        		drinkers.add(cd.Consumer_Name__c);
        		tempInt++;
        		//At first iteration this shouldn't happen
        		if(tempInt != 1){
        			tempDrinks.remove(tempDrinks.size()-1);
        			whoDrankWhat.put(drinkers[tempInt-1], tempDrinks);
        			tempDrinks.clear();
        			tempDrinks.add(cd);
        		}
        	}
        	//On last iteration the list should be added to the map
        	if(endIsNear == consumedDrinks.size()) whoDrankWhat.put(drinkers[tempInt-1], tempDrinks);
        	endIsNear++;
        }
    }
    
    public List<Consumed_Drink__c> getOnesDrinks(String DrinkerName){
    	return whoDrankWhat.get(DrinkerName);
    }
    
    public PageReference consume(){
    	System.debug('DeeeBug: UserId='+currentUserId+' Consumed_Drink_Type__c='+clickedProduct);
    	insert new Consumed_Drink__c(UserId__c = currentUserId, Consumed_Drink_Type__c = clickedProduct, Quantity__c = 1);
    	return null;
    }

}