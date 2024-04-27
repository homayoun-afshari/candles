# Candles
Candles is a standalone application designed by <a href="https://it.mathworks.com/products/matlab/app-designer.html">MATLAB App Designer<a> to provide professional analysis tools for Iranian Stock Market:
1. Oscillators: MFI, RSI, and Full Stochastic.
2. Indicators: Basic Volume Movement, Expert Volume Movement, Ichimoku, and Price Levels.
3. Strategies: Miner.

# Code Execution
## Data Scraper
Run [scrape.m](scrape.m) to download the required data from <a href="http://www.tsetmc.com/tsev2/data/instinfodata.aspx">tsetmc.com</a>. The data scraper sends successive GET requests to the server until it downloads and updates the data currently stored in the [data](data) folder.

## GUI
The following video is a demonstration of how the application works in MATLAB environment. To deploy the project as a standalone application, please refer to <a href="https://it.mathworks.com/matlabcentral/answers/1928010-how-do-i-deploy-an-app-designer-application-to-a-standalone-desktop-app">this post</a>.
https://github.com/homayoun-afshari/candles/assets/120579983/40a227e2-31a8-495e-8672-5bd8286bf738

