import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Client httpClient;
  Web3Client ethClient;
  bool data = false;
  double _currentSliderValue = 0;
  String _currentTextValue = '';

  final myAddress = "0x8795eCea6c2cE6108904d40278b82198A6683a50";

  var myData, myText;
  String txHash;

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    // print(httpClient);
    ethClient = Web3Client(
        "https://rinkeby.infura.io/v3/b2a9d5831e3b4675a51144cfed03bafa",
        httpClient);
    getBalance(myAddress);
    getSmartText(myAddress);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0xffea39599508f7c5Da498EF657117285907b15a2";

    final contract = DeployedContract(ContractAbi.fromJson(abi, "PKCoin"),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  // ********* IMPORTANT ********* //
  // ==== This is to get the information only ==== //
  // ==== Get method ==== //
  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    //
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);

    // This line below doesn't work.
    final result = await ethClient.call(
      contract: contract,
      function: ethFunction,
      params: args,
    );

    // print(result.toString());
    return result;
  }

  Future<void> getBalance(String targetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> result = await query("getBalance", []);

    setState(() {
      myData = result[0];
      data = true;
    });
  }

  Future<void> getSmartText(String targetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> result = await query("getSmartText", []);

    setState(() {
      myText = result[0];
      data = true;
    });
  }

  // ********* IMPORTANT ********* //
  // ==== This is to set the information only ==== //
  // ==== set method ==== //
  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials =
        EthPrivateKey.fromHex("Your Secret Key from Metamask");

    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: args,
      ),
      fetchChainIdFromNetworkId: true,
    );
    return result;
  }

  Future<String> sendCoin() async {
    var bigAmount = BigInt.from(_currentSliderValue);

    var response = await submit("depositBalance", [bigAmount]);

    print("Deposited");
    setState(() {
      txHash = response.toString();
    });
    print(txHash);
    print(response);
    return response;
  }

  Future<String> withdrawCoin() async {
    var bigAmount = BigInt.from(_currentSliderValue);

    var response = await submit("withdrawBalance", [bigAmount]);

    print("Withdrawn");
    return response;
  }

  Future<String> setSmartText() async {
    var myText = _currentTextValue;

    var response = await submit("setSmartText", [myText]);

    print("setSmartText");
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example'),
      ),
      body: Container(
        // color: Colors.blue,
        padding: EdgeInsets.symmetric(vertical: 50),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'My Balance',
              ),
              data
                  ? Text(
                      '$myData',
                      style: Theme.of(context).textTheme.headline4,
                    )
                  : CircularProgressIndicator(),
              SizedBox(height: 10),
              Text(
                'Smart Text',
              ),
              data
                  ? Text(
                      '$myText',
                      style: Theme.of(context).textTheme.headline4,
                    )
                  : CircularProgressIndicator(),
              SizedBox(height: 10),
              Container(
                color: Colors.red,
                child: FlatButton(
                  onPressed: () {
                    getBalance(myAddress);
                  },
                  child: Text("Get Balance"),
                ),
              ),
              SizedBox(height: 10),
              Container(
                color: Colors.red,
                child: FlatButton(
                  onPressed: () {
                    getSmartText(myAddress);
                  },
                  child: Text("Get SmartText"),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 300,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  onChanged: (val) {
                    setState(() {
                      _currentSliderValue = double.parse(val);
                    });
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                color: Colors.blue,
                child: FlatButton(
                  onPressed: () async {
                    await sendCoin();
                  },
                  child: Text("Deposit"),
                ),
              ),
              SizedBox(height: 10),
              Container(
                color: Colors.green,
                child: FlatButton(
                  onPressed: () async {
                    await withdrawCoin();
                  },
                  child: Text("Withdraw"),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 300,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  onChanged: (val) {
                    setState(() {
                      _currentTextValue = val;
                    });
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                color: Colors.green,
                child: FlatButton(
                  onPressed: () async {
                    await setSmartText();
                  },
                  child: Text("Smart Text"),
                ),
              ),
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
