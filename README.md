# reversal_learning
A set of matlab scripts to fit a Q-learning model to 2-choice-data (response/reward) using softmax as decision rule and log-likelihood for model fitting.

Q learning algorithms implemented here are based on "Trial-by-trial data analysis using computational models" by Nathaniel D. Daw, http://www.princeton.edu/~ndaw/d10.pdf

In brief, if a subject makes a choice ct (Left or Right) on a trial t, then the Q value for that choice(L or R) on the subsequent trial will be 
Qt+1(ct) = Qt(ct) +α·δt 
where the prediction error 
δt = rt − Qt(ct)
depends on the presence or the abscence or the reward (i.e. whether rt=1 or rt=0). Please note that here a separate α is modelled for the presence and abscence of the reward, alpha_reward and alpha_no_reward. 

Using the Q values placed on each of the two choices (left or right), decision probabilities are computed using the softmax rule with the inverse temperature parameter β.

# 1. q_learning_script.m
q_learning_script will run simulations of an agent performing a reversal learning task (the reward contingencies are switched after 9/10  correct responses are made; the task finishes after 3 reversals are achieved). Its output is in the variable "summary", which includes one cell for each combination of parameters alpha_reward, alpha_no_reward and beta that is listed in the index-variable. For each combination of the three parameters, 100 iterations of the task are ran. Depending on how advantageous the combination, it will take the simulated agent more or fewer trials to finish the task.

# 2. Qfit2data.m
Qfit2data requires a data input. It is currently set up to import text files such as "1.txt" using readtable. 4 example datasets are uploaded, too. If they are in the same directory as Qfit2data.m, and specified in subject_list, they will be imported and each output variable will have 4 rows, one for each subject.

For each datafile imported, it will compute the Q and decision probability values, then compute the probability density function 
PDF(alpha_reward, alpha_no_reward, beta) and pick the maximum of log(PDF). PDF is computed as the product of probabilities of observing the sequence of responses fed into Qfit2data.m. 

It will then compute a pseudo R-square measure that first calculates the probability of observing the sequence of responses at random (each response probability=0.5) and then calculates pseudo_R2 as
pseudo_R2=(PDF-r)/r

It also allows for plotting a PDF of all 3 parameters in 3d to explore how quickly the PDF declines around the maximum, i.e. how well do the alternative combinations of parameters fit the data compared to the best combination. 

The outputs are:
1) R2_fit
2) best_fit_params
3) PDF_all 
4) BIC_all
# 3. CI_fitting.m
CI_fitting will attempt to compute the CIs on the parameter combination using the Hessian of the PDF (2nd order derivative). This function is not completed yet. It needs the output from Qfit2data.m, more specifically the PDF for all subjects.

# 4. Qfit2data_2params and Qfit2data_2params_AUTOCORREL
Qfit2data_2params is a simplified version of Qfit2data, which models only one learning parameter alpha, taking learning from reward and non-reward trials to happen at the same rate. Qfit2data_2params_AUTOCORREL extends Qfit2data_2params by modelling choice autocorrelation.
To compare the models (Qfit2data_2params vs Qfit2data_2params_AUTOCORREL or Qfit2data_2params vs Qfit2data with 3 parameters), the variable d (log probability of observing the data given the model with its best fitting parameters) is created. 
Log likelihood ratio: 
2*(d(model1)-d(model2)) 
follows a chi square distribution and p-values can be obtained by comparing the fit of two models using the log likelihood ratio. 

The outputs are:
1) R2_fit
2) best_fit_params
3) PDF_all 
4) d
5) Bayesian Information Criterion, BIC

# 5. pi_fit2data
pi_fit2data is a simple policy based learning model with the standard softmax rule. Model_evidence variable could be used to compare it to the other models - it is the average of the log likelihoods for all the parameter sets that were probed in a given model.  

# 6. Visualising_results & more info
Scripts for some simple figures can be found in Visualising_results and an overview of the theory (following Daw 2009) with sample results can be found in Reversal_modelling.pdf

# 7. Analytic parameter selection
The script Analytic_Qfit2data_2_params creates a continuous PDF for two parameters, [alpha and beta] and then uses matlab's fmincon to locally minimize the log-probability function. It also creates a surface plot of the probability of observing the data given any combination of the parameters [alpha, beta]. The best fit parameters selected by the analytic solution are closest to the best fit parameters selected from the discrete parameter space in the Qfit2data_2params script before. 
