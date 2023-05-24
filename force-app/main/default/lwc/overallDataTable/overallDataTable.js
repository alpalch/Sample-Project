/**
 * @description       : This is a table with all proposals for the opportunity
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 24-05-2023
 * @last modified by  : @ValeriyPalchenko
**/
import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import editProposalModal from 'c/editProposalModal';
import createProposalModal from 'c/createProposalModal';
import searchEquipmentModal from 'c/searchEquipmentModal';
import deleteProposalModal from 'c/deleteProposalModal';
import deleteEquipmentModal from 'c/deleteEquipmentModal';
import editProposalTableModal from 'c/editProposalTableModal';

import getTableData from '@salesforce/apex/OverallDataTableController.getTableData';
import updateIsExpandedField from '@salesforce/apex/OverallDataTableController.updateIsExpandedField';

const ERROR_TOAST_TITLE = 'Error';
const ERROR_TOAST_VARIANT = 'error';
const ERROR_TOAST_MESSAGE = 'Something went wrong. Ask your administrator to check logs.';

const columns = [{ name: 'Proposal Name', width: 'width: 20%', },
                 { name: 'Status', width: 'width: 20%', },
                 { name: 'Related Proposal Equipments', width: 'width: 20%', },
                 { name: 'Quantity', width: 'width: 30%', },
                 { name: 'Total Cost', width: 'width: 10%', },
                 { name: 'Margin', width: 'width: 10%', },
                 { name: 'Total Price', width: 'width: 10%', },
                 { name: 'Actions', width: 'width: 10%',}];

export default class OverallDataTable extends LightningElement {
    
    @api recordId;
    @track tableData = [];
    error;
    columns = columns;
    isDisabledAddButton = false;
    isFirstLoadFlag = true;
    wiredOpportunity = {};

    

    @wire(getTableData, { opportunityId: '$recordId' })
        wiredGetTableData(value) {
            this.wiredTableData = value;
            const { data, error } = value;
            if(data) {
                this.error = undefined;
                // This is needed to avoid error when cannot read property of undefined
                if(data.length === 0) {
                    this.tableData = [{
                        opportunityTotalCost: 0,
                        opportunityTotalPrice: 0,
                        opportunityMargin: 0,
                        opportunityTotalQuantity: 0,
                    }];
                } else {
                    this.tableData = JSON.parse(JSON.stringify(data));
                    this.tableData.forEach(proposal => {
                        if(this.isFirstLoadFlag) {
                            proposal.proposalIsExpanded = false;
                            proposal.iconName = 'utility:chevronright';
                        }
                        console.log('1');
                        proposal.isDisabled = proposal.proposalStatus === 'Draft' ? false : true;
                        proposal.iconName = proposal.proposalIsExpanded ? 'utility:chevrondown' : 'utility:chevronright';
                    });
                }

                // avoiding divide by zero error
                this.tableData[0].opportunityMargin = 0;
                if(this.tableData[0].opportunityTotalCost !== 0) {
                    this.tableData[0].opportunityMargin = (this.tableData[0].opportunityTotalPrice / this.tableData[0].opportunityTotalCost - 1) * 100;
                }

                this.wiredOpportunity = {
                    Margin: Math.round(this.tableData[0].opportunityMargin),
                    TotalCost: this.tableData[0].opportunityTotalCost,
                    TotalPrice: this.tableData[0].opportunityTotalPrice,
                    TotalQuantity: this.tableData[0].opportunityTotalQuantity,
                };
                if(this.tableData[0].opportunityStageName === 'Appointment Scheduled' || 
                   this.tableData[0].opportunityStageName === 'Preparing Proposal' ||
                   this.tableData[0].opportunityStageName === undefined) {
                    this.isDisabledAddButton = false;
                } else {
                    this.isDisabledAddButton = true;
                }
            }
            if(error) {
                this.error = error;
                console.log('error: ', error.message);
                this.showErrorToast();
            }
            
        }

    handleOpenEditProposalModal(event) {
        editProposalModal.open({
            size: 'medium',
            description: 'This is modal window for editing proposal',
            proposalId: event.target.value,
            opportunityId: this.recordId,
            onsuccessfulupdatedproposal: (saveEvent) => {
                saveEvent.stopPropagation();
                this.refreshTable(saveEvent.detail);
            }
        });
    }

    handleOpenCreateProposalModal() {
        createProposalModal.open({
            size: 'medium',
            description: 'This is modal window for adding new proposal',
            opportunityId: this.recordId,
            onsuccessfulcreatedproposal: (event) => {
                event.stopPropagation();
                this.refreshTable(event.detail);
            }
        });
    }

    handleOpenSearchEquipmentModal(event) {
        searchEquipmentModal.open({
            size: 'medium',
            description: 'This is modal window for adding equipment',
            proposalId: event.target.value,
            onsuccessfuladdedequipment: (saveEvent) => {
                saveEvent.stopPropagation();
                this.refreshTable(saveEvent.detail);
            }
        });
    }

    handleOpenDeleteProposalModal(event) {
        deleteProposalModal.open({
            size: 'medium',
            description: 'This is modal window for deleting proposal',
            proposalId: event.target.value,
            onsuccessfulproposaldelete: (saveEvent) => {
                saveEvent.stopPropagation();
                this.refreshTable(saveEvent.detail);
            }
        });
    }

    handleOpenDeleteEquipmentModal(event) {
        deleteEquipmentModal.open({
            size: 'medium',
            description: 'This is modal window for deleting equipment',
            equipmentId: event.target.value,
            onsuccessfulequipmentdelete: (saveEvent) => {
                saveEvent.stopPropagation();
                this.refreshTable(saveEvent.detail);
            }
        });
    }

    handleOpenEditProposalTableModal(event) {
        editProposalTableModal.open({
            size: 'medium',
            description: 'This is modal window for editing proposal table',
            proposalId: event.target.value,
            onsuccessfulupdatedequipment: (saveEvent) => {
                saveEvent.stopPropagation();
                this.refreshTable(saveEvent.detail);
            }
        });
    }

    handleRowsExpand(event) {
        this.tableData.forEach(proposal => {
            if(proposal.proposalId === event.target.value) {
                proposal.proposalIsExpanded = !proposal.proposalIsExpanded;
                proposal.iconName = proposal.proposalIsExpanded ? 'utility:chevrondown' : 'utility:chevronright';
                event.target.iconName = proposal.iconName;
            }
        });
    }

    refreshTable(key) {
        this.isFirstLoadFlag = false;
        if(key === 'success') {
            this.updateIsExpandedField();
        }
    }

    updateIsExpandedField() {
        const jsonTableData = JSON.stringify(this.tableData);
        updateIsExpandedField({ proposalData: jsonTableData })
            .then(() => {
                refreshApex(this.wiredTableData);
            })
            .catch(error => {
                this.error = error;
                console.log('error: ', this.error);
                this.showErrorToast();
            });
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: ERROR_TOAST_TITLE,
            message: ERROR_TOAST_MESSAGE,
            variant: ERROR_TOAST_VARIANT,
        });
        this.dispatchEvent(event);
    }
}