/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 07-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
import { LightningElement, wire, track } from 'lwc';
import getEquipmentCategories from '@salesforce/apex/ModalPicklistAndSearchboxController.getEquipmentCategories';

export default class ModalPicklistAndSearchbox extends LightningElement {

    errors;
    selectedCategory;
    textEquipmentName;
    clickedButtonLabel;
    categories =[];
    
    @wire(getEquipmentCategories)
    transformDataForOptions({data, error}){
        if(data){
            this.errors = undefined;
           // data.forEach(element => this.categories.push( {label: element.Name, value: element.Id} ));
            this.categories = data.map(element => ({ label: element.Name, value: element.Id }));
        }
        if (error){
            this.errors = error;
            this.categories = undefined;
        }
    }

    handleChange(event) {
        this.selectedCategory = event.detail.value;
    }

    handleInputFocus(event) {
        // modify parent to properly highlight visually
        const classList = event.target.parentNode.classList;
        classList.add('lgc-highlight');
    }

    handleInputBlur(event) {
        // modify parent to properly remove highlight
        const classList = event.target.parentNode.classList;
        classList.remove('lgc-highlight');
    }

    handleInputChange(event) {
        this.textEquipmentName = event.detail.value;
    }

    handleClick(event) {
        this.clickedButtonLabel = this.textEquipmentName + '/' + this.selectedCategory;
        const searchEvent = new CustomEvent('getsearchvalue', {detail: this.clickedButtonLabel});
        this.dispatchEvent(searchEvent);
    }
}