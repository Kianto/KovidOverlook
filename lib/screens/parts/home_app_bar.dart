import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kovidoverlook/collectors/continent_col.dart';
import 'package:kovidoverlook/models/continent.dart';
import 'package:kovidoverlook/models/report.dart';
import 'package:kovidoverlook/widgets/continent_card.dart';
import 'package:kovidoverlook/widgets/summary_card.dart';
import 'package:kovidoverlook/widgets/summary_chart.dart';

class HomeAppBar extends StatefulWidget {
  HomeAppBar({
    super.key,
    required this.continent,
    this.onContinentSelected,
    this.reports = const [],
  }) : continents = ContinentCollection.getContinents();

  final Continent continent;
  final Function(Continent)? onContinentSelected;
  final List<Continent> continents;
  final List<Report> reports;

  @override
  _HomeAppBarState createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  final _carouselController = CarouselSliderController();
  int _pointer = 0;

  @override
  Widget build(BuildContext context) {
    if ('*' != widget.continent.id) {
      if (0 == widget.continent.total) {
        _pointer = 0;
      }
      for (int i = _pointer; i < widget.reports.length; i++) {
        widget.continent.confirmed += widget.reports[i].confirmed;
        widget.continent.recovered += widget.reports[i].recovered;
        widget.continent.deaths += widget.reports[i].deaths;
        _pointer++;
      }
    }
    return _buildBody();
  }

  Widget _buildBody() {
    var continentList = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 188,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.continents.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(right: 14),
            child: ContinentCard(
              continent: widget.continents[index],
              onTap: (continent) {
                widget.onContinentSelected?.call(continent);
                _carouselController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.linear,
                );
              },
              selected: widget.continent == widget.continents[index],
            ),
          ),
        ),
      ),
    );

    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;

    var summaryList = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2 / 1,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        children: [
          SummaryCard(
            color: theme.colorScheme.primary.withValues(alpha: 0.85),
            title: 'Total',
            number: widget.continent.total.toInt(),
          ),
          SummaryCard(
            color: Colors.blue.shade600,
            title: 'Confirmed',
            number: widget.continent.confirmed,
          ),
          SummaryCard(
            color: Colors.green.shade600,
            title: 'Recovered',
            number: widget.continent.recovered,
          ),
          SummaryCard(
            color: Colors.red.shade600,
            title: 'Deaths',
            number: widget.continent.deaths,
          ),
        ],
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
    );

    var appContent = Column(
      children: [
        const SizedBox(height: 56.0),
        continentList,
        Expanded(
          child: Stack(
            children: [
              Center(child: summaryList),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 124,
                  width: 124,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.12),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: SummaryChart(
                      report: widget.continent,
                      size: 50.0,
                      showPercent: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 56.0),
            Expanded(
              child: CarouselSlider(
                options: CarouselOptions(height: double.infinity),
                items: widget.continents
                    .map(
                      (i) => Builder(
                        builder: (context) => i.image == null
                            ? const SizedBox()
                            : Image.asset(
                                i.image!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    )
                    .toList(),
                carouselController: _carouselController,
              ),
            ),
          ],
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.surface.withValues(alpha: 0.0),
                theme.colorScheme.secondary.withValues(alpha: 0.12),
                theme.colorScheme.surface,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        appContent,
      ],
    );
  }
}
