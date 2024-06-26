const axios = require('axios');
require('dotenv').config();

module.exports = async (req, res) => {
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
            return response.data;
        } catch (error) {
            console.error('Error fetching data:', error);
            return { error: 'Error fetching data' };
        }
    };

    const data = await fetchData();
    res.status(200).json(data);
};
