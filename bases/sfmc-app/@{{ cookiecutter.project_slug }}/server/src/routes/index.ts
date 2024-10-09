import path from 'path';
import { Router } from 'express';

const router = Router();

router.get('/', function(req, res) {
  process.env.NODE_ENV === 'production' ?
    res.sendFile(path.join(__dirname, '..', 'public', 'index.html')) :
    res.redirect('http://localhost:3000');
});

export default router;
