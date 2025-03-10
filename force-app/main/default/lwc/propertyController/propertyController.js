import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getPaginatedProperties from '@salesforce/apex/PropertyController.getPaginatedProperties';
import getTotalPropertyCount from '@salesforce/apex/PropertyController.getTotalPropertyCount';

const PAGE_SIZE = 25; // Number of records per page

export default class PropertyController extends NavigationMixin(LightningElement) {
    @track properties = [];
    @track totalRecords = 0;
    @track currentPage = 1;
    totalPages = 0;
    
    // Filter Parameters
    minPrice = 0;
    maxPrice = 100000;
    selectedStatus = '';
    selectedFurnishing = '';
    userLatitude;
    userLongitude;
    maxDistance = 50; // Default 50 km

    // Status and Furnishing Options
    statusOptions = [
        { label: 'All', value: '' },
        { label: 'Available', value: 'Available' },
        { label: 'Occupied', value: 'Occupied' }
    ];

    furnishingOptions = [
        { label: 'All', value: '' },
        { label: 'Furnished', value: 'Furnished' },
        { label: 'Semi-Furnished', value: 'Semi-Furnished' },
        { label: 'Unfurnished', value: 'Unfurnished' }
    ];

    connectedCallback() {
        this.fetchUserLocation();
        this.fetchProperties();  // Ensure properties load on initial render
       // this.fetchTotalRecords();
    }
    

    fetchUserLocation() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                position => {
                    this.userLatitude = position.coords.latitude;
                    this.userLongitude = position.coords.longitude;
                    this.fetchProperties();
                },
                error => {
                    console.warn('Geolocation permission denied or unavailable');
                    this.fetchProperties(); // Ensure properties load even if location is unavailable
                }
            );
        } else {
            this.fetchProperties(); // Fallback to fetching properties without geolocation
        }
    }
    
    fetchTotalRecords() {
        getTotalPropertyCount({
            pageSize: PAGE_SIZE,
            minPrice: this.minPrice || 0, 
            maxPrice: this.maxPrice || 100000,
            status: this.selectedStatus || '',
            furnishingStatus: this.selectedFurnishing || '',
            latitude: this.userLatitude || null,
            longitude: this.userLongitude || null,
            maxDistance: this.maxDistance || null
        })
            .then(result => {
                this.totalRecords = result;
                this.totalPages = Math.ceil(result / PAGE_SIZE);
               // this.fetchProperties();
            })
            .catch(error => console.error('Error fetching total count:', error));
    }

    async fetchProperties() {
        console.log('Fetching Properties: Page', this.currentPage);
    
        await getPaginatedProperties({
            pageNumber: this.currentPage,  // Ensure the updated page number is used
            pageSize: PAGE_SIZE,
            minPrice: this.minPrice || 0, 
            maxPrice: this.maxPrice || 100000,
            status: this.selectedStatus || '',
            furnishingStatus: this.selectedFurnishing || '',
            latitude: this.userLatitude || null,
            longitude: this.userLongitude || null,
            maxDistance: this.maxDistance || null
        })
        .then(result => {
            console.log('Properties Fetched for Page:', this.currentPage, result);  
            this.properties = result;
            this.fetchTotalRecords();
        })
        .catch(error => {
            console.error('Error fetching properties:', error);
        });
    }
    
    
    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            console.log('Next Page Clicked - New Page:', this.currentPage); // 🛠 Debug Log
            this.fetchProperties();
        }
    }
    
    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage--;
            console.log('Previous Page Clicked - New Page:', this.currentPage); // 🛠 Debug Log
            this.fetchProperties();
        }
    }
    
    

    async handleFilterChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;
        this.currentPage = 1;
        await this.fetchProperties();
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }
    
    get isNextDisabled() {
        return this.currentPage >= this.totalPages; // Ensure correct last-page logic
    }
    
    handleNewProperty() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Property__c', // Replace with your object API name
                actionName: 'new'
            }
        });
    }

}