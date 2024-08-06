const express = require('express');
const axios = require('axios');
const router = express.Router();

router.post('/', async (req, res) => {
  const { tp_TIN } = req.body;
  const token = req.headers.authorization;

  try {
    const response = await axios.post(
      'https://ebms.obr.gov.bi:9443/ebms_api/checkTIN',
      { tp_TIN },
      { headers: { Authorization: token } }
    );
    res.json(response.data);
  } catch (error) {
    res.status(error.response.status).json(error.response.data);
  }
});

module.exports = router;
