const axios = require('axios');
require('dotenv').config();

const BASE_URL = process.env.BASE_URL;
const USERNAME = process.env.USERNAME;
const PASSWORD = process.env.PASSWORD;

const fetchData = async () => {
    try {
        const response = await axios.post(
            `${BASE_URL}/api/endpoint`, 
            { /* Request body if any */ },
            {
                auth: {
                    username: USERNAME,
                    password: PASSWORD
                }
            }
        );
        console.log('Data:', response.data);
    } catch (error) {
        console.error('Error fetching data:', error);
    }
};

// Stream data every 10 seconds
setInterval(fetchData, 10000);
