# reversal_learning
A set of matlab scripts to fit a Q-learning model to 2-choice-data (response/reward) using softmax as decision rule and log-likelihood for model fitting.

Q learning algorithm implemented here are based on "Trial-by-trial data analysis using computational models" by Nathaniel D. Daw, http://www.princeton.edu/~ndaw/d10.pdf

In brief, if a subject makes a choice ct (Left or Right) on a trial t, then the Q value for that choice(L or R) on the subsequent trial will be 
Qt+1(ct) = Qt(ct) +α·δt 
where the prediction error 
δt = rt − Qt(ct)
depends on the presence or the abscence or the reward (i.e. whether rt=1 or rt=0). Please note that here a separate α is modelled for the presence and abscence of the reward, alpha_reward and alpha_no_reward. 

Using the Q values placed on each of the two choices (left or right), decision probabilities are computed using the softmax rule with the inverse temperature parameter β.

# 1. q_learning_script.m
q_learning_script will run simulations of an agent performing a reversal learning task (the reward contingencies are switched after 9/10  correct responses are made; the task finishes after 3 reversals are achieved). Its output is in the variable "summary", which includes one cell for each combination of parameters alpha_reward, alpha_no_reward and beta that is listed in the index-variable. For each combination of the three parameters, 100 iterations of the task are ran. Depending on how advantageous the combination, it will take the simulated agent more or fewer trials to finish the task.

# 2. Qfit2data.m
Qfit2data requires a data input. It is currently set up to import text files such as "example.txt" using readtable. 
For each datafile imported, it will compute the Q and decision probability values, then compute the probability density function 
PDF(alpha_reward, alpha_no_reward, beta) and pick the maximum of log(PDF). PDF is computed as the product of probabilities of observing the sequence of responses fed into Qfit2data.m. 

It will then compute a pseudo R-square measure that first calculates the probability of observing the sequence of responses at random (each response probability=0.5) and then calculates pseudo_R2 as
pseudo_R2=(PDF-r)/r

It also allows for plotting a PDF of all 3 parameters in 3d to explore how quickly the PDF declines around the maximum, i.e. how well do the alternative combinations of parameters fit the data by comparison the best combination. 

The outputs are:
1) R2_fit
2) best_fit_params
3) PDF_all 

# 3. CI_fitting.m
CI_fitting will attempt to compute the CIs on the parameter combination using the Hessian of the PDF (2nd order derivative). This function is not completed yet. It needs the output from Qfit2data.m, more specifically the PDF for all subjects.

