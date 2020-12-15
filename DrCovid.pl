% Shahir Chowdhury
% December 14th, 2020
% 
% This basic chatbot lets the user input a series of symptoms, and then weights the likelihood of each symptom corresponding
% to a given illness they may have. It only tracks 4 illnesses at the moment (but they are all similar so the distinction this
% bot makes will be important)  
% Symptoms knowledge base according to https://intermountainhealthcare.org/blogs/topics/live-well/2020/03/whats-the-difference-between-a-cold-the-flu-and-coronavirus/
%

% Knowledge base
often(fever, covid).
often(fever, flu).
often(fatigue, seasonal).
often(cough, covid).
often(cough, flu).
often(cough, seasonal).
often(sneezing, cold).
often(sneezing, seasonal).
often(aches, flu).
often(aches, cold).
often(runny_nose, cold).
often(runny_nose, seasonal).
often(sore_throat, cold).
often(headaches, flu).
often(difficulty_breathing, covid).
often(loss_of_taste_or_smell, covid).

sometimes(fever, seasonal).
sometimes(fatigue, covid).
sometimes(fatigue, flu).
sometimes(fatigue, cold).
sometimes(cough, cold).
sometimes(aches, covid).
sometimes(runny_nose, flu).
sometimes(sore_throat, covid).
sometimes(sore_throat, flu).
sometimes(diarrhea, flu).
sometimes(headache, covid).
sometimes(headache, seasonal).

rare(fever, cold).
rare(stuffy_nose, covid).
rare(diarrhea, covid).
rare(runny_nose, covid).
rare(headaches, cold).
rare(difficulty_breathing, flu).
rare(difficulty_breathing, cold).
rare(difficulty_breathing, seasonal).
rare(loss_of_taste_or_smell, flu).
rare(loss_of_taste_or_smell, cold).
rare(loss_of_taste_or_smell, seasonal).

no(sneezing, covid).
no(sneezing, flu).
no(aches, seasonal).
no(sore_throat, seasonal).
no(diarrhea, cold).
no(diarrhea, seasonal).

noMatch(_,_).       % no match means the symptom is not recorded in the database

% Run the program
diagnose():-
    retractall(symptom(_)),
    writeln('Note: This chatbot is by no means a medical expert and its advice does not substitute for a proper medical diagnosis.'),
    getSymptoms(List),
    getSymptomScores(List, 0, 0, 0, 0).

% base cases compare scores of all symptoms, highest scoring is predicted, and in case of ties COVID-19 has priority
getSymptomScores([], CovidScore, FluScore, ColdScore, SeasonalScore):-
    CovidScore = 0, FluScore = 0, ColdScore = 0, SeasonalScore = 0,
    writeln('You are the healthiest person alive and the definition of what peak performance looks like.').
getSymptomScores([], CovidScore, FluScore, ColdScore, SeasonalScore):-
    CovidScore >= FluScore, CovidScore >= ColdScore, CovidScore >= SeasonalScore, 
    writeln('You may have COVID-19. Please get tested.').
getSymptomScores([], CovidScore, FluScore, ColdScore, SeasonalScore):-
    FluScore >= CovidScore, FluScore >= ColdScore, FluScore >= SeasonalScore, 
    writeln('You may have the flu. Check the last time you were vaccinated and see a doctor if it gets bad.').
getSymptomScores([], CovidScore, FluScore, ColdScore, SeasonalScore):-
    ColdScore >= CovidScore, ColdScore >= FluScore, ColdScore >= SeasonalScore, 
    writeln('You probably have the common cold. No worries.').
getSymptomScores([], CovidScore, FluScore, ColdScore, SeasonalScore):-
    SeasonalScore >= CovidScore, SeasonalScore >= FluScore, SeasonalScore >= ColdScore, 
    writeln('If you have seasonal allergies, they are probably acting up right now.').
% go through each symptom and update values until list is empty
getSymptomScores([Head|Tail], CovidScore, FluScore, ColdScore, SeasonalScore):- 
    updateCovid(Head, CovidScore, CovidScoreNew), 
    updateFlu(Head, FluScore, FluScoreNew),
    updateCold(Head, ColdScore, ColdScoreNew),
    updateSeasonal(Head, SeasonalScore, SeasonalScoreNew),
    getSymptomScores(Tail, CovidScoreNew, FluScoreNew, ColdScoreNew, SeasonalScoreNew).

% Functions that increment all illness values based on the likelihood of the illness
updateCovid(Head, CovidScore, CovidScoreNew) :-
    often(Head, covid) -> CovidScoreNew is CovidScore + 3;
    sometimes(Head, covid) -> CovidScoreNew is CovidScore + 2;
    rare(Head, covid) -> CovidScoreNew is CovidScore + 1;
    no(Head, covid) -> CovidScoreNew is CovidScore;
    noMatch(Head, covid) -> CovidScoreNew is CovidScore.
updateFlu(Head, FluScore, FluScoreNew) :-
    often(Head, flu) -> FluScoreNew is FluScore + 3;
    sometimes(Head, flu) -> FluScoreNew is FluScore + 2;
    rare(Head, flu) -> FluScoreNew is FluScore + 1;
    no(Head, flu) -> FluScoreNew is FluScore;
    noMatch(Head, flu) -> FluScoreNew is FluScore.
updateCold(Head, ColdScore, ColdScoreNew) :-
    often(Head, cold) -> ColdScoreNew is ColdScore + 3;
    sometimes(Head, cold) -> ColdScoreNew is ColdScore + 2;
    rare(Head, cold) -> ColdScoreNew is ColdScore + 1;
    no(Head, cold) -> ColdScoreNew is ColdScore;
    noMatch(Head, cold) -> ColdScoreNew is ColdScore.
updateSeasonal(Head, SeasonalScore, SeasonalScoreNew) :-
    often(Head, seasonal) -> SeasonalScoreNew is SeasonalScore + 3;
    sometimes(Head, seasonal) -> SeasonalScoreNew is SeasonalScore + 2;
    rare(Head, seasonal) -> SeasonalScoreNew is SeasonalScore + 1;
    no(Head, seasonal) -> SeasonalScoreNew is SeasonalScore;
    noMatch(Head, seasonal) -> SeasonalScoreNew is SeasonalScore.

% Ask the user to continue to input symptoms until they say "stop."
getSymptoms([Symptom|List]):-
    writeln('Please enter a symptom (type "stop." to stop inputting):'),
    read(Symptom),
    dif(Symptom,stop),
    getSymptoms(List).
getSymptoms([]).