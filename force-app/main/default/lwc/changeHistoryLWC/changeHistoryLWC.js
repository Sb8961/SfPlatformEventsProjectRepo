import { LightningElement, wire, api } from 'lwc';
import fetchApexResultMethod from '@salesforce/apex/changeHistoryApexClass.fetchApexResultMethod';
import RecordTypeId from '@salesforce/schema/Account.RecordTypeId';

const COLUMNS = [
    { label: 'Field Name', fieldName: 'Field_Name__c', type: 'text' },
    { label: 'Old Field Value', fieldName: 'Old_Field_Value__c', type: 'text' },
    { label: 'New Field Value', fieldName: 'New_Field_Value__c', type: 'text' },
   // { label: 'Record Type Name', fieldName: 'Record_Type_Id__c', type: 'text' },
    { label: 'Last Modified User Name', fieldName: 'User_Name__c', type: 'text' },
    { label: 'Modified Date', fieldName: 'SystemModstamp', type: 'date' }
];

export default class ChangeHistoryLWC extends LightningElement {
 
    @api recordId;   // <-- gets current Account Id
  
   /* connectedCallback() {
        alert('RecordId: ' + this.recordId);
    } */ 


    columns = COLUMNS;

    @wire(fetchApexResultMethod, { accountId: '$recordId' })
    changeHistoryDetails;
    
}