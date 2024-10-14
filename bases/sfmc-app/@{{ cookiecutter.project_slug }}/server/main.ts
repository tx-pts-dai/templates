import server from './src/server';
import logger from './src/utils/logger';

(async () => {

    // check that all secrets are deployed
    [
      'SFMC_CLIENT_ID',
      'SFMC_CLIENT_SECRET',
      'SFMC_SUBDOMAIN',
      'SFMC_ACCOUNT_ID',
      'SFMC_JWT_SECRET',
    //   'SFMC_DE_ACCOUNTS',
    //   'AFFINITY_DE_24',
    //   'AFFINITY_DE_BZ',
    //   'AFFINITY_DE_ZU',
    //   'AFFINITY_DE_TT',
    //   'AFFINITY_DE_TG',
    //   'AFFINITY_DE_TA',
    //   'AFFINITY_DE_LB',
    //   'AFFINITY_DE_BU',
    //   'AFFINITY_DE_BO',
    //   'AFFINITY_DE_ZS',
    //   'AFFINITY_DE_LT',
    //   'AFFINITY_DE_BS'
    ].forEach(_var => {
        if(!process.env[_var]) {
            throw new Error(`The required env variable "${_var}" is not set!`);
        }
    });

    const port = parseInt(process.env.PORT || '8080');

    server.on('error', (error: NodeJS.ErrnoException) => {
        if (error.syscall !== 'listen') {
            throw error;
        }

        const bind = typeof port === 'string'
            ? 'Pipe ' + port
            : 'Port ' + port;

        // handle specific listen errors with friendly messages
        switch (error.code) {
            case 'EACCES':
              logger.error(bind + ' requires elevated privileges');
              process.exit(1);
            case 'EADDRINUSE':
              logger.error(bind + ' is already in use');
              process.exit(1);
            default:
              throw error;
        }
    });

    server.on('listening', () => {
        const addr = server.address();
        const bind = typeof addr === 'string'
          ? 'pipe ' + addr
          : 'port ' + addr?.port;

        logger.info(`Server has been started and listening on ${bind}`)
    });

    server.listen(port);
})()
