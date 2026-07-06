class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final configurationEngine = ConfigurationEngine();

  late ConfigurationState configuration;

  @override
  void initState() {
    super.initState();

    configuration = ConfigurationState.initial();
  }

  void _move(ConfigurationMove move) {
    setState(() {
      configuration =
          configurationEngine.applyMove(
            configuration,
            move,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PadlockAppBar(),

      body: Column(
        children: [

          SentencePreview(
            configuration.sentenceState,
          ),

          SubjectWheel(
            viewport: configuration.subjectViewport,
            onMove: _move,
          ),

          VerbWheel(
            viewport: configuration.verbViewport,
            onMove: _move,
          ),

          ModalWheel(
            viewport: configuration.modalViewport,
            onMove: _move,
          ),

          AspectWheel(
            viewport: configuration.aspectViewport,
            onMove: _move,
          ),

          TenseWheel(
            viewport: configuration.tenseViewport,
            onMove: _move,
          ),

          PlaceWheel(
            viewport: configuration.placeViewport,
            onMove: _move,
          ),

          TimeWheel(
            viewport: configuration.timeViewport,
            onMove: _move,
          ),

          VoiceToggle(
            state: configuration.voiceToggle,
            onMove: _move,
          ),

          PolarityToggle(
            state: configuration.polarityToggle,
            onMove: _move,
          ),

          GuidedPanel(
            configuration.messages,
          ),
        ],
      ),
    );
  }
}

class VerbWheel extends StatelessWidget {
  final WheelViewport<Verb> viewport;

  final ValueChanged<ConfigurationMove> onMove;

  const VerbWheel({
    super.key,
    required this.viewport,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return PadlockWheel<Verb>(
      viewport: viewport,

      onForward: () {
        onMove(
          RotateVerbForward(),
        );
      },

      onBackward: () {
        onMove(
          RotateVerbBackward(),
        );
      },
    );
  }
}

class PadlockWheel<T> extends StatelessWidget {
  final WheelViewport<T> viewport;

  final VoidCallback onForward;

  final VoidCallback onBackward;

  ...
}