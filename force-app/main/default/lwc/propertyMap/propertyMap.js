import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Property__c.Geolocation__Latitude__s',
    'Property__c.Geolocation__Longitude__s'
];

export default class PropertyMap extends LightningElement {
    @api recordId;
    mapMarkers = [];
    mapCenter = { Latitude: 11.1271, Longitude: 78.6569 }; // Default center (Tamil Nadu)

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredProperty({ error, data }) {
        if (data) {
            const latitude = data.fields.Geolocation__Latitude__s.value;
            const longitude = data.fields.Geolocation__Longitude__s.value;

            if (latitude && longitude) {
                this.mapMarkers = [
                    {
                        location: { Latitude: latitude, Longitude: longitude },
                        title: 'Property Location',
                        description: 'This is the selected property location.'
                    }
                ];

                this.mapCenter = { Latitude: latitude, Longitude: longitude };
            }
        } else if (error) {
            console.error('Error fetching property location:', error);
        }
    }
}