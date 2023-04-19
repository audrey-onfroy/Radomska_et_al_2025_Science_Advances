# mpnst_paper



singularity exec singularity_from_dir.simg Rscript -e "rmarkdown::render(
input = '/home/aurelien/Documents/Audrey/git_radomska/1_mice/1_metadata/1_build_metadata.Rmd',
output_file = '/home/aurelien/Documents/Audrey/git_radomska/1_mice/1_metadata/1_build_metadata.html')"




sample="2019_A"; singularity exec --bind /mnt/Data/
/home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages_dir/singularity_from_dir.simg
Rscript -e "rmarkdown::render(input = './1_make_individual.Rmd', output_file = './individual_${sample}.html', params = list(sample_name = '${sample}'))"



for sample in $(ls ../0_input/)
do
    echo $sample
    singularity exec --bind /mnt/Data/ /home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages_dir/singularity_from_dir.simg Rscript -e "rmarkdown::render(input = './1_make_individual.Rmd', output_file = './individual_${sample}.html', params = list(sample_name = '${sample}'))"
done