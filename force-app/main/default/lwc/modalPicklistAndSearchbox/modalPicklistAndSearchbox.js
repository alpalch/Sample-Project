import { LightningElement, wire, track } from 'lwc';
import getEquipmentCategories from '@salesforce/apex/ModalPicklistAndSearchboxController.getEquipmentCategories';

export default class ModalPicklistAndSearchbox extends LightningElement {

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

    errors;
    selectedCategory;

   /* get options() {
        return this.categories;
    }
*/
    handleChange(event) {
        this.selectedCategory = event.detail.value;
    }

    textEquipmentName;

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
    clickedButtonLabel;

    handleClick(event) {
        this.clickedButtonLabel = this.textEquipmentName + '/' + this.selectedCategory;
        const searchEvent = new CustomEvent('getsearchvalue', {detail: this.clickedButtonLabel});
        this.dispatchEvent(searchEvent);
    }
}