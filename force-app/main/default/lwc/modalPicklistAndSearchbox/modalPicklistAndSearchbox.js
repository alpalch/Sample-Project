import { LightningElement, wire } from 'lwc';
import getEquipmentCategories from '@salesforce/apex/ModalPicklistAndSearchboxController.getEquipmentCategories';

export default class ModalPicklistAndSearchbox extends LightningElement {
    @wire(getEquipmentCategories)
    transformDataForOptions({data, error}){
        if(data){
            this.errors = undefined;
            data.forEach(element => this.categories.push( {label: element.Name, value: element.Name} ));
            console.log(1);
        }
        if (error){
            this.errors = error;
            this.categories = undefined;
        }
    }

    categories =[];
    errors;
    selectedCategory;

    get options() {
        return this.categories;
    }

    handleChange(event) {
        this.selectedCategory = event.detail.value;
    }

    textValue;

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
        this.textValue = event.detail.value;
    }
    clickedButtonLabel;

    handleClick(event) {
        this.clickedButtonLabel = this.textValue + ' ' + this.selectedCategory;
    }
}
