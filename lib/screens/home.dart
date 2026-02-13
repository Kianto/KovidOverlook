import 'package:flutter/material.dart';
import 'package:kovidoverlook/collectors/continent_col.dart';
import 'package:kovidoverlook/collectors/country_col.dart';
import 'package:kovidoverlook/models/continent.dart';
import 'package:kovidoverlook/models/country.dart';
import 'package:kovidoverlook/models/report.dart';
import 'package:kovidoverlook/screens/parts/home_body.dart';
import 'package:kovidoverlook/utils/constant.dart';
import 'package:kovidoverlook/widgets/animation_notifier.dart';
import 'package:provider/provider.dart';

import 'parts/home_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Continent? _selectingContinent;

  late AnimationController _animationCtrler;

  @override
  void initState() {
    super.initState();

    _animationCtrler = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      reverseDuration: const Duration(milliseconds: 500),
    );
    _animationCtrler.forward();

    ContinentCollection.initCountryListIntoContinents(context).then((_) {
      ContinentCollection.getContinentReport('*').then(
        (value) => setState(() => _selectingContinent = value),
      );
    });
  }

  @override
  void dispose() {
    _animationCtrler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => AnimationNotifier(_animationCtrler),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: StreamBuilder<List<Country>>(
        stream: CountryCollection.getCountriesByContinentStream(
          _selectingContinent?.id ?? '',
        ),
        initialData: const [],
        builder: (context, snapshot) {
          List<Country> countries = snapshot.data ?? [];
          return CustomScrollView(
            slivers: <Widget>[
              _buildAppbar(_selectingContinent, countries),
              _buildList(countries),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppbar(Continent? continent, List<Report> reports) {
    final theme = Theme.of(context);
    return SliverAppBar(
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 2,
      title: Text(
        Constants.appName,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      floating: true,
      expandedHeight: MediaQuery.of(context).size.height * 2 / 3,
      flexibleSpace: FlexibleSpaceBar(
        background: HomeAppBar(
          continent: ContinentCollection.getContinentByCode(continent?.id) ??
              Continent(name: 'None'),
          onContinentSelected: _onContinentSelected,
          reports: reports,
        ),
      ),
    );
  }

  Widget _buildList(List<Country> countries) {
    return SliverList(
      delegate: SliverChildListDelegate([
        HomeBody(countries: countries),
      ]),
    );
  }

  void _onContinentSelected(Continent continent) => setState(() {
        if (_selectingContinent == continent) return;
        // else
        if (_animationCtrler.status == AnimationStatus.completed) {
          _animationCtrler.reverse();
          Future.delayed(const Duration(milliseconds: 600)).then((value) {
            _animationCtrler.stop();
            _animationCtrler.forward();
          });
        }

        _selectingContinent = continent;
      });
}
