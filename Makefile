report/report.html: report.Rmd \
 data/NBA_2025_per_minute_clean.csv \
 code/clean_data.R \
 output/primary_regression_table.rds \
 output/bargraph.rds \
 output/scatterplot_output.png \
 output/table1.rds \
 code/render.R
	Rscript code/Render.R
	
data/NBA_2025_per_minute_clean.csv: code/clean_data.R
	@echo "Building CSV..."
	Rscript code/clean_data.R
	
output/primary_regression_table.rds: code/models.r
	Rscript code/models.r
	
output/bargraph.rds: code/NBA_bargraph.R
	Rscript code/NBA_bargraph.R

output/scatterplot_output.png: code/SCATTERPLOT_CODE.R
	Rscript code/SCATTERPLOT_CODE.R

output/table1.rds: code/table1.R
	Rscript code/table1.R
	
clean:
	rm -f Rplots.pdf\
				data/NBA_2025_per_minute_clean.csv\
				data/NBA_2025_per_minute_raw.html\
	      output/bargraph.rds\
	      output/primary_regression_table.rds\
	      output/scatterplot_output.png\
	      output/table1.rds\
	      report/report.html\
	      code/NBA_2025_per_minute_raw.html\
	      Rplots.pdf\
	      
.PHONY: all clean