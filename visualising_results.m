%for cocaine group all data
alpha=	[0.32	0.34	0.02	0.98	0.14	0.04	0.12	0.24	0.12	0.72	0.96	0.10	0.02		0.00	0.58	0.98	0.98	0.06	0.24	0.28	0.22	0.02	0.10]
beta= [1.49	1.61	1.77	1.01	2.93	2.59	2.75	0.79	2.07	2.07	1.07	1.23	1.23		0.01	0.63	0.49	0.53	2.99	1.91	2.31	2.11	2.99	2.99]

%comparing LLR in 2 model vs 3 model test
LLR_alpha3_vs_2param = [-2.807725106	-2.027355893	-11.10817085	-0.229646631	-2.431169312	-0.816438187	-3.030595225	-0.081672866	-0.200288742	-0.064859502	-0.104232721	-3.712785886	-0.961820336		-0.017677968	-0.009502609	0           -0.208851708	-1.693699473	-0.529394717	-5.282797327	-1.733321667	0       -0.125820873;		-3.671186704	-1.454692314	-6.065353489	0	-1.24200215	-0.814267031	-2.41470551	-6.117065475	-2.846076847	-7.86493008	-2.118698166	-0.208122148	-2.202022969	-4.415946039	-0.729054664	-1.33604125	-3.629086225	-0.303896097	-14.89682851	-4.074246211	-0.474378908		-4.577671564	-4.891538088];
LLR_alpha3_vs_2param=LLR_alpha3_vs_2param*-1
LLR_kappa3_vs_2param = [2.807725106	1.653144663	11.44400618	2.447620402	3.80118525	9.513419837	0.095915178	13.87910841	0.265407657	0.256097095	-0.009999572	5.862039259	2.661895447		1.359658811	8.2963725	4.798952918	0.940428676	4.43839817	2.186295493	0.489360847	0.833828759	-0.037016785	0.208176681;		0.403091526	-0.007232571	4.072828152	-0.039418158	0.930493141	0.074453289	11.49821973	0.294232866	1.658423727	1.043141639	4.39789125	3.688971851	-0.012346088	10.56234852	3.646511728	0.465048283	0.206465427	0.574976618	5.189980624	-0.025702747	1.649514493	 3.80562516	0.505492977];
x=[1,2];
barh(LLR_alpha3_vs_2param, 'r');
        title('Model 2 vs Model 3')
        xlabel('Likelihood Ratio Test (d)');
        yticklabels({'Cocaine', 'Controls'});
        hold on;
        x1=3.84;
        y1=get(gca,'ylim');
        plot([x1 x1],y1);
        set(findall(gca, 'Type', 'Line'),'LineWidth',2);
        
barh(LLR_kappa3_vs_2param, 'b');
        title('Model 2 vs Model 4')
        xlabel('Likelihood Ratio Test (d)');
        yticklabels({'Cocaine', 'Controls'});
        hold on;
        x1=3.84;
        y1=get(gca,'ylim');
        plot([x1 x1],y1);
        set(findall(gca, 'Type', 'Line'),'LineWidth',2);
        
pvalues_d=1-chi2cdf(LLR_alpha3_vs_2param,1)
        
Evidence_based_vs_free=[-0.253882558	-0.303467378	-0.178916623	-0.189569496	-0.130353313	-0.236465403	-0.137299083	-0.416382301	0.015050341     0.061520375     -0.078979584	-0.105868326	-0.091922698		-0.190875788	-0.357166417	-0.10309863	-0.017432435	-0.096454741	-0.198443784	-0.024287324	-0.186233863	-0.141177907	-0.083149586;	-0.076930409	-0.040497343	-0.053028535	-0.007146895	0.023068676	-0.037781375	-0.063210626	-0.036012795	0.008835382	-0.14698527	-0.113177689	-0.139998829	-0.112381386	-0.223346844	-0.318882916	-0.015968514	0.058573633	-0.096220397	-0.370319818	-0.175128981	-0.011122101		0.023011296	0.009611614]
barh(Evidence_based_vs_free);
        title('Q-Learning (left) vs Policy Learning (right)')
        xlabel('log Model Evidence Ratio');
        yticklabels({'Cocaine', 'Controls'});
        



%https://uk.mathworks.com/help/matlab/ref/errorbar.html
ma=mean(alpha)
mb=mean(beta)
sa=std(alpha)/sqrt(23)
sb=std(beta)/sqrt(23)
errorbar(ma, mb,yneg,ypos,xneg,xpos,'o')
yneg=sb
ypos=sb
xneg=sa
xpos=sa
xlim manual
ylim([0 3]);
xlim([0 1]);
PDF_mat_HE=zeros(length(PDF),0);
subject_list_HE=[5	22	1	16	23	18	3	6	4	8	13	15];
for subject=subject_list_HE;
    subject_mat=(PDF_all{subject})';
    PDF_mat_HE=horzcat(PDF_mat_HE, subject_mat);
end;
subject_list_LE=[2	9	7	11	19	10	24	12	21	17	20];

PDF_mat_LE=zeros(length(PDF),0);
for subject=subject_list_LE;
    subject_mat=(PDF_all{subject})';
    PDF_mat_LE=horzcat(PDF_mat_LE, subject_mat);
end;

for i=1:length(PDF);
    mean_PDF_HE(i)=mean(PDF_mat_HE(i, :));
end
mean_PDF_HE=mean_PDF_HE';
for i=1:length(PDF);
    mean_PDF_LE(i)=mean(PDF_mat_LE(i, :));
end
mean_PDF_LE=mean_PDF_LE';

mean_PDF_HE=mean_PDF_HE+2;

cline(index(:,2), index(:,3), mean_PDF_LE, mean_PDF_HE);
upperl=max(mean_PDF_LE)+3;
lowerl=max(mean_PDF_LE)-5;
zlim([lowerl upperl]);
        xlabel('beta');
        ylabel('kappa');
        zlabel('log(P(D|M,theta)');
hold on
cline(index(:,2), index(:,3), mean_PDF_HE, 'b');



plot3(index(:,2), index(:,3), mean_PDF_LE);
upperl=max(mean_PDF_LE)+3;
lowerl=max(mean_PDF_LE)-5;
zlim([lowerl upperl]);
        xlabel('beta');
        ylabel('kappa');
        zlabel('log(P(D|M,theta)');
hold on
plot3(index(:,2), index(:,3), mean_PDF_HE);





mean_HE_Reshaped=reshape(mean_PDF_HE,[50, 63, 26]);
surf(k, j, mean_HE_Reshaped(:,:,1))
