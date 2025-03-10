import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import jsPDFResource from '@salesforce/resourceUrl/jsPDF';
import { loadScript } from 'lightning/platformResourceLoader';
import sendEmailWithPDF from '@salesforce/apex/LeaseAgreementController.sendEmailWithPDF';


// Lease Agreement Schema Fields
const FIELDS = [
    'Lease_Agreement__c.Id',
    'Lease_Agreement__c.Terms__c',
    'Lease_Agreement__c.Agreed_Monthly_Rent__c',
    'Lease_Agreement__c.Start_Date__c',
    'Lease_Agreement__c.End_Date__c',
    'Lease_Agreement__c.Property__r.Name',
    'Lease_Agreement__c.Property__r.Address__c',
    'Lease_Agreement__c.Tenant__r.Name',
    'Lease_Agreement__c.Tenant__r.Email__c'
];

export default class LeaseAgreementPdf extends LightningElement {
    @api recordId;
    leaseData;
    isJsPdfLoaded = false;

    // Load jsPDF Library
    connectedCallback() {
        loadScript(this, jsPDFResource)
            .then(() => {
                console.log('✅ jsPDF Loaded Successfully');
                this.isJsPdfLoaded = true;
                this.jsPDFInstance = window.jspdf?.jsPDF || null;
    
                if (!this.jsPDFInstance) {
                    console.error('❌ jsPDF instance not found');
                }
            })
            .catch(error => {
                console.error('❌ Error Loading jsPDF:', error);
                this.showToast('Error', 'Failed to load PDF library', 'error');
            });
    }

    // Fetch Lease Agreement Data
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredLease({ error, data }) {
        if (data) {
            console.log('✅ Lease Data Retrieved:', JSON.stringify(data));
    
            // Debugging: Print all available fields
            console.log('🔹 Available Fields:', Object.keys(data.fields));
    
            // Ensure safe access using optional chaining
            const fields = data.fields;
            this.leaseData = {
                id: data.id,
                terms: fields?.Terms__c?.value || 'N/A',
                rent: fields?.Agreed_Monthly_Rent__c?.value || 'N/A',
                startDate: fields?.Start_Date__c?.value || 'N/A',
                endDate: fields?.End_Date__c?.value || 'N/A',
                propertyName: fields?.Property__r?.value?.fields?.Name?.value || 'N/A',
                propertyAddress: fields?.Property__r?.value?.fields?.Address__c?.value || 'N/A',
                tenantName: fields?.Tenant__r?.value?.fields?.Name?.value || 'N/A',
                tenantEmail: fields?.Tenant__r?.value?.fields?.Email__c?.value || 'N/A'
            };
    
            console.log('✅ Processed Lease Data:', JSON.stringify(this.leaseData));
    
        } else if (error) {
            console.error('❌ Error fetching lease data:', JSON.stringify(error));
            this.showToast('Error', 'Failed to retrieve lease data', 'error');
        }
    }
    


    // Generate and Download PDF
    generatePdf() {
        if (!this.leaseData) {
            console.error('❌ Lease data is missing!');
            this.showToast('Error', 'Lease data is missing!', 'error');
            return;
        }
        if (!this.isJsPdfLoaded || !this.jsPDFInstance) {
            console.error('❌ jsPDF is not loaded yet!');
            this.showToast('Error', 'PDF Library is not loaded!', 'error');
            return;
        }
    
        console.log('🚀 generatePdf() function triggered!');
        console.log('jsPDF Instance:', this.jsPDFInstance);
    
        const { tenantName, tenantEmail, propertyName, propertyAddress, terms, rent, startDate, endDate } = this.leaseData;
        const doc = new this.jsPDFInstance();
    
        doc.text(`Lease Agreement`, 10, 10);
        doc.text(`Tenant: ${tenantName}`, 10, 20);
        doc.text(`Email: ${tenantEmail}`, 10, 30);
        doc.text(`Property: ${propertyName}`, 10, 40);
        doc.text(`Address: ${propertyAddress}`, 10, 50);
        doc.text(`Terms: ${terms}`, 10, 60);
        doc.text(`Rent: ${rent}`, 10, 70);
        doc.text(`Start Date: ${startDate}`, 10, 80);
        doc.text(`End Date: ${endDate}`, 10, 90);
    
        doc.save(`Lease_Agreement_${this.recordId}.pdf`);
        console.log('✅ PDF should now be downloading!');
    
        this.showToast('Success', 'Lease Agreement PDF generated successfully!', 'success');
    }
    
    
    

    // Send Email with PDF
    sendEmail() {
        console.log('🚀 Calling Apex sendEmailWithPDF with Record ID:', this.recordId);
        sendEmailWithPDF({ recordId: this.recordId })
            .then(response => {
                console.log('✅ Email sent successfully:', response);
                this.showToast('Success', 'Lease Agreement Email Sent Successfully!', 'success');
            })
            .catch(error => {
                console.error('❌ Error Sending Email:', error);
                this.showToast('Error', `Failed to send email: ${JSON.stringify(error)}`, 'error');
            });
    }
    
    

    // Show Toast Messages
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
}