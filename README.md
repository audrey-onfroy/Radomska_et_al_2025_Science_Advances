# mpnst_paper



singularity exec singularity_from_dir.simg Rscript -e "rmarkdown::render(
input = '/home/aurelien/Documents/Audrey/git_radomska/1_mice/1_metadata/1_build_metadata.Rmd',
output_file = '/home/aurelien/Documents/Audrey/git_radomska/1_mice/1_metadata/1_build_metadata.html')"




for sample in $(ls ../0_input/)
do
    echo $sample
    singularity exec --bind /mnt/Data/ /home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages_dir/singularity_from_dir.simg Rscript -e "rmarkdown::render(input = './1_make_individual.Rmd', output_file = './individual_${sample}.html', params = list(sample_name = '${sample}'))"
done


singularity exec --bind /mnt/Data/ /home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages_dir/singularity_from_dir.simg Rscript -e "rmarkdown::render(input = '3_combined_mice.Rmd', output_file = '3_combined_mice.html')"

singularity exec --bind /mnt/Data/ /home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages_dir/singularity_from_dir.simg Rscript -e "rmarkdown::render(input = '41_tumor_cells_dataset.Rmd', output_file = '41_tumor_cells_dataset.html')"

singularity exec --bind /mnt/Data/ /home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages_dir/singularity_from_dir.simg Rscript -e "rmarkdown::render(input = '42_tumor_cells_subdataset.Rmd', output_file = '42_tumor_cells_subdataset.html')"


singularity exec --bind /mnt/Data/ /home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages_dir/singularity_from_dir.simg Rscript -e "rmarkdown::render(input = '44_trajectory_tinga.Rmd', output_file = '44_trajectory_tinga.html')"


singularity exec --bind /mnt/Data/ /home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages_dir/singularity_from_dir_copie.simg Rscript -e "rmarkdown::render(input = '45_trajectory_slingshot.Rmd', output_file = '45_trajectory_slingshot.html')"

singularity exec --bind /mnt/Data/ /home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages_dir/singularity_from_dir.simg Rscript -e "rmarkdown::render(input = '46_functional_enrichment.Rmd', output_file = '46_functional_enrichment.html')"









singularity exec --bind /mnt/Data/ /home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages_dir/singularity_from_dir.simg Rscript -e "rmarkdown::render(input = '1_build_metadata.Rmd', output_file = '1_build_metadata.html')"


for sample in $(ls ../0_input/)
do
    echo $sample
    singularity exec --bind /mnt/Data/ /home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages_dir/singularity_from_dir.simg Rscript -e "rmarkdown::render(input = './1_make_individual.Rmd', output_file = './individual_${sample}.html', params = list(sample_name = '${sample}'))"
done