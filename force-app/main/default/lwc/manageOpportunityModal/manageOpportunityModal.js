/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 25-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
import { api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions'
import { refreshApex } from '@salesforce/apex';

import LightningModal from 'lightning/modal';

import getOpportunityProductsData from '@salesforce/apex/ManageOpportunityModalController.getOpportunityProductsData';
import handleProductSearch from '@salesforce/apex/ManageOpportunityModalController.handleProductSearch';
import createOpportunityChildren from '@salesforce/apex/ManageOpportunityModalController.createOpportunityChildren';
import getAlreadyCreatedChilds from '@salesforce/apex/ManageOpportunityModalController.getAlreadyCreatedChilds';

const productColumns = [{label: 'Product Name', fieldName: 'Name', type: 'text'},
                         {label: 'Product Description', fieldName: 'Description', type: 'text'},
                         {label: 'Price', fieldName: 'UnitPrice', type: 'currency', cellAttributes: { alignment: 'center' }},];

const treeGridColumns = [{name: 'Opportunity Name'},
                         {name: 'Product Name'},
                         {name: 'Price'},
                         {name: 'Delete'}];

const ERROR_TOAST_TITLE = 'Error';
const ERROR_TOAST_VARIANT = 'error';
const SUCCESS_TOAST_TITLE = 'Success';
const SUCCESS_TOAST_VARIANT = 'success';
const SUCCESS_TOAST_MESSAGE = 'Success';

export default class ManageOpportunityModal extends LightningModal {
    @api recordId;
    @track opportunityProductsData = [];
    @track alreadyCreatedChilds = [];
    @track treeGridData = [];
    parentOpportunity = {};
    dataForSave = [];
    productColumns = productColumns;
    treeGridColumns = treeGridColumns;
    error;
    clonedOpportunityName;
    searchKey;

    connectedCallback() {
        this.setTargetWidth();
    }

     // fills left table
    @wire(getOpportunityProductsData, { parentOpportunityId: '$recordId' })
        wiredGetopportunityPropoductsData(value) {
            this.wiredOpportunityPropoductsData = value;
            const { data, error } = value;
            if(data) {
                JSON.parse(data).forEach(opportunity => {
                    this.parentOpportunity.id = opportunity.parentOpportunityId;
                    this.parentOpportunity.name = opportunity.parentOpportunityName;
                    this.parentOpportunity.stage = opportunity.parentOpportunityStage;
                    this.parentOpportunity.closeDate = opportunity.parentOpportunityCloseDate;
                    this.parentOpportunity.amount = opportunity.parentOpportunityAmount;
                    opportunity.lineItems.forEach(lineItem => {
                        this.opportunityProductsData.push(lineItem);
                    })
                });
                this.opportunityProductsData = JSON.parse(JSON.stringify(this.opportunityProductsData));
            }
            if(error) {
                this.error = error;
                console.log(error);
                this.showErrorToast();
            }
        }

    //fills right table
    @wire(getAlreadyCreatedChilds, { parentOpportunityId: '$recordId' })
        wiredGetAlreadyCreatedChilds(value) {
            this.wiredAlreadyCreatedChilds = value;
            const { data, error } = value;
            if(data) {
                this.alreadyCreatedChilds = JSON.parse(data).map(opportunity => ({
                    opportunityId: opportunity.opportunityId,
                    opportunityName: opportunity.opportunityName,
                    productName: '',
                    productPrice: '',
                    iconName: 'utility:chevronright',
                    opportunityIsExpanded: false,
                    lineItems: opportunity.lineItems.map(lineItem => ({
                        opportunityId: opportunity.opportunityId,
                        opportunityName: opportunity.opportunityName,
                        product2Id: lineItem.Product2Id,
                        productId: lineItem.Id,
                        productName: lineItem.Name,
                        productPrice: lineItem.UnitPrice,
                        quantity: lineItem.Quantity,
                        description: lineItem.Description,
                    })),
                }));
                this.alreadyCreatedChilds.forEach(opportunity => {
                    this.treeGridData.push(opportunity);
                })
                this.treeGridData = JSON.parse(JSON.stringify(this.treeGridData));
            }
            if(error) {
                this.error = error;
                console.log(error);
                this.showErrorToast();
            }
        }

    handleDeleteProduct(event) {
        this.treeGridData.forEach(opportunity => {
            opportunity.lineItems.forEach((lineItem, index = 0) => {
                if(lineItem.productId === event.target.value) {
                    this.opportunityProductsData.push({
                        Id: lineItem.productId,
                        Name: lineItem.productName,
                        OpportunityId: lineItem.opportunityId,
                        Product2Id: lineItem.product2Id,
                        Quantity: lineItem.quantity,
                        UnitPrice: lineItem.productPrice,
                        Description: lineItem.description,
                    });
                    this.opportunityProductsData = JSON.parse(JSON.stringify(this.opportunityProductsData));
                    opportunity.lineItems.splice(index, 1);
                }
                index++
            });
        });
    }

    handleDeleteOpportunity(event) {
        this.treeGridData.forEach((opportunity, index) => {
            if(opportunity.opportunityName === event.target.value) {
                opportunity.lineItems.forEach(lineItem => {
                    this.opportunityProductsData.push({
                        Id: lineItem.productId,
                        Name: lineItem.productName,
                        OpportunityId: lineItem.opportunityId,
                        Product2Id: lineItem.product2Id,
                        Quantity: lineItem.quantity,
                        UnitPrice: lineItem.productPrice,
                        Description: lineItem.description,
                    })
                });
                this.opportunityProductsData = JSON.parse(JSON.stringify(this.opportunityProductsData));
                this.treeGridData.splice(index, 1);
            }
            index++;
        });
    }

    handleRowsExpand(event) {
        this.treeGridData.forEach(opportunity => {
            if(opportunity.opportunityName === event.target.value) {
                opportunity.opportunityIsExpanded = !opportunity.opportunityIsExpanded;
                opportunity.iconName = opportunity.opportunityIsExpanded ? 'utility:chevrondown' : 'utility:chevronright';
                event.target.iconName = opportunity.iconName;
            }
        });
    }

    handleAddOpportunity() {
        const dataTable = this.template.querySelector('.opportunity-products-table');
        const selectedRows = dataTable.getSelectedRows();
        if(this.checkOpportunityName()) {
            this.treeGridData.push({
                opportunityId: '',
                opportunityName: this.clonedOpportunityName,
                productName: '',
                productPrice: '',
                iconName: 'utility:chevrondown',
                opportunityIsExpanded: true,
                lineItems: selectedRows.map(lineItem => ({
                    opportunityId: '',
                    opportunityName: this.clonedOpportunityName,
                    product2Id: lineItem.Product2Id,
                    productId: lineItem.Id,
                    productName: lineItem.Name,
                    productPrice: lineItem.UnitPrice,
                    quantity: lineItem.Quantity,
                    description: lineItem.Description,
                }))
            });
            this.treeGridData = JSON.parse(JSON.stringify(this.treeGridData));
        } else {
            this.treeGridData.forEach(opportunity => {
                if(opportunity.opportunityName === this.clonedOpportunityName) {
                    selectedRows.forEach(lineItem => {
                        opportunity.lineItems.push({
                            opportunityId: '',
                            opportunityName: this.clonedOpportunityName,
                            product2Id: lineItem.Product2Id,
                            productId: lineItem.Id,
                            productName: lineItem.Name,
                            productPrice: lineItem.UnitPrice,
                            quantity: lineItem.Quantity,
                            description: lineItem.Description,
                        });
                    });                
                }
            });
            this.treeGridData = JSON.parse(JSON.stringify(this.treeGridData));
        }
        this.removeOpportunityProducts(selectedRows);
    }

    handleOpportunityNameChange(event) {
        this.clonedOpportunityName = event.detail.value;
    }

    handleSearchInput(event) {
        this.searchKey = event.detail.value;
        this.handleSearch();
    }

    handleSearch() {
        handleProductSearch({ searchKey: this.searchKey, opportunityId: this.recordId })
        .then((data) => {
            this.opportunityProductsData = JSON.parse(data);
            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
            console.log('error: ', error.message);
        });
    }
    
    handleSave() {
        this.prepareDataForSave();
        createOpportunityChildren({ opportunitiesData: JSON.stringify(this.dataForSave), parentOpportunityId: this.recordId })
        .then(() => {
            console.log('success');
            this.setDeafultWidth();
            this.showSuccessToast();
            this.refreshData();
            this.dispatchEvent(new CloseActionScreenEvent());
        })
        .catch(error => {
            console.log(error);
            this.showErrorToast('Error has been happen during the code execution. Contact you admin. Error: ' + error.body.message);
        });
    }
    
    handleCancel() {
        this.setDeafultWidth();
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    checkOpportunityName() {
        let returnFlag = true;
        if(!this.clonedOpportunityName) {
            this.showErrorToast('Please enter Opportunity Name');
            return false;
        }
        this.treeGridData.forEach(opportunity => {
            if(opportunity.opportunityName === this.clonedOpportunityName) {
                returnFlag =  false;
            }
        });
        return returnFlag;
    }

    removeOpportunityProducts(selectedRows) {
        selectedRows.forEach(row => {
            let index = this.opportunityProductsData.indexOf(row);
            for(let i = 0; i < this.opportunityProductsData.length; i++) {
                if(this.opportunityProductsData[i].Id === row.Id) {
                    index = i;
                    break;
                }
            }
            this.opportunityProductsData.splice(index, 1);
        });
        this.opportunityProductsData = JSON.parse(JSON.stringify(this.opportunityProductsData))
    }

    setTargetWidth() {
        let div = document.querySelectorAll(".slds-modal__container");
        div[0].style.width = "70%";
        div[0].style.minWidth = "80%";
        div[0].style.maxWidth = "80%";
    }

    setDeafultWidth() {
        let div = document.querySelectorAll(".slds-modal__container");
        div[0].style.width = "70%";
        div[0].style.minWidth = "480px";
        div[0].style.maxWidth = "840px";
    }

    showErrorToast(message) {
        const event = new ShowToastEvent({
            title: ERROR_TOAST_TITLE,
            message: message,
            variant: ERROR_TOAST_VARIANT,
        });
        this.dispatchEvent(event);
    }

    showSuccessToast() {
        const event = new ShowToastEvent({
            title: SUCCESS_TOAST_TITLE,
            message: SUCCESS_TOAST_MESSAGE,
            variant: SUCCESS_TOAST_VARIANT,
        });
        this.dispatchEvent(event);
    }
    
    prepareDataForSave() {
        this.treeGridData.forEach(opportunity => {
            this.dataForSave.push({
                opportunityId: opportunity.opportunityId,
                parentOpportunityId: this.recordId,
                opportunityName: opportunity.opportunityName,
                lineItems: opportunity.lineItems.map(lineItem => ({
                    OpportunityId: lineItem.opportunityId,
                    Product2Id: lineItem.product2Id,
                    UnitPrice: lineItem.productPrice,
                    Name: lineItem.productName,
                    Id: lineItem.productId,
                    Quantity: lineItem.quantity,
                    Description: lineItem.description,
                }))
            });
        });
    }

    refreshData() {
        refreshApex(this.wiredOpportunityPropoductsData);
        refreshApex(this.wiredAlreadyCreatedChilds);
    }
}