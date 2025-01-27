section \<open> Unrestriction \<close>

theory Unrestriction
  imports Expressions
begin

text \<open> Unrestriction means that an expression does not depend on the value of the state space
  described by the given scene (i.e. set of variables) for its valuation. It is a semantic
  characterisation of fresh variables. \<close>

consts unrest :: "'s scene \<Rightarrow> 'p \<Rightarrow> bool"

definition unrest_expr :: "'s scene \<Rightarrow> ('b, 's) expr \<Rightarrow> bool" where
[expr_defs]: "unrest_expr a e = (\<forall> s s'. e (s \<oplus>\<^sub>S s' on a) = e s)"

adhoc_overloading unrest unrest_expr

syntax
  "_unrest" :: "salpha \<Rightarrow> logic \<Rightarrow> logic \<Rightarrow> logic" (infix "\<sharp>" 20)

translations
  "_unrest x p" == "CONST unrest x p"                                           

named_theorems unrest

lemma unrest_empty [unrest]: "\<emptyset> \<sharp> P"
  by (simp add: expr_defs lens_defs)

lemma unrest_var_union [unrest]:
  "\<lbrakk> A \<sharp> P; B \<sharp> P \<rbrakk> \<Longrightarrow> A \<union> B \<sharp> P"
  by (simp add: expr_defs lens_defs)
     (metis scene_override_union scene_override_unit scene_union_incompat)

lemma unrest_neg_union:
  assumes "A ##\<^sub>S B" "- A \<sharp> P" "- B \<sharp> P"
  shows "(- (A \<union> B)) \<sharp> P"
  using assms by (simp add: unrest_expr_def scene_override_commute scene_override_union)

text \<open> The following two laws greatly simplify proof when reasoning about unrestricted lens,
  and so we add them to the expression simplification set. \<close>

lemma unrest_lens [expr_simps]:
  "mwb_lens x \<Longrightarrow> ($x \<sharp> e) = (\<forall> s v. e (put\<^bsub>x\<^esub> s v) = e s)"
  by (simp add: unrest_expr_def var_alpha_def comp_mwb_lens lens_override_def)
     (metis mwb_lens.put_put)

lemma unrest_compl_lens [expr_simps]:
  "mwb_lens x \<Longrightarrow> (- $x \<sharp> e) = (\<forall>s s'. e (put\<^bsub>x\<^esub> s' (get\<^bsub>x\<^esub> s)) = e s)"
  by (simp add: unrest_expr_def var_alpha_def comp_mwb_lens lens_override_def scene_override_commute)

lemma unrest_subscene: "\<lbrakk> idem_scene a; a \<sharp> e; b \<subseteq>\<^sub>S a \<rbrakk> \<Longrightarrow> b \<sharp> e"
  by (metis subscene_eliminate unrest_expr_def)

lemma unrest_lens_comp [unrest]: "\<lbrakk> mwb_lens x; mwb_lens y; $x \<sharp> e \<rbrakk> \<Longrightarrow> $x:y \<sharp> e"
  by (simp add: unrest_lens, simp add: lens_comp_def ns_alpha_def)

lemma unrest_expr [unrest]: "x \<sharp> e \<Longrightarrow> x \<sharp> (e)\<^sub>e"
  by (simp add: expr_defs)

lemma unrest_lit [unrest]: "x \<sharp> (\<guillemotleft>v\<guillemotright>)\<^sub>e"
  by (simp add: expr_defs)

lemma unrest_var [unrest]: 
  "\<lbrakk> vwb_lens x; idem_scene a; var_alpha x \<bowtie>\<^sub>S a \<rbrakk> \<Longrightarrow> a \<sharp> ($x)\<^sub>e"
  by (auto simp add: unrest_expr_def scene_indep_override var_alpha_def)
     (metis lens_override_def lens_override_idem mwb_lens_weak vwb_lens_mwb weak_lens_def)

lemma unrest_var_single [unrest]:
  "\<lbrakk> mwb_lens x; x \<bowtie> y \<rbrakk> \<Longrightarrow> $x \<sharp> ($y)\<^sub>e"
  by (simp add: expr_defs lens_indep.lens_put_irr2 lens_indep_sym lens_override_def var_alpha_def)

lemma unrest_conj [unrest]:
  "\<lbrakk> x \<sharp> P; x \<sharp> Q \<rbrakk> \<Longrightarrow> x \<sharp> (P \<and> Q)\<^sub>e"
  by (auto simp add: expr_defs)

lemma unrest_not [unrest]:
  "\<lbrakk> x \<sharp> P \<rbrakk> \<Longrightarrow> x \<sharp> (\<not> P)\<^sub>e"
  by (auto simp add: expr_defs)

lemma unrest_disj [unrest]:
  "\<lbrakk> x \<sharp> P; x \<sharp> Q \<rbrakk> \<Longrightarrow> x \<sharp> (P \<or> Q)\<^sub>e"
  by (auto simp add: expr_defs)

lemma unrest_implies [unrest]:
  "\<lbrakk> x \<sharp> P; x \<sharp> Q \<rbrakk> \<Longrightarrow> x \<sharp> (P \<longrightarrow> Q)\<^sub>e"
  by (auto simp add: expr_defs)

lemma unrest_uop:
  "\<lbrakk> x \<sharp> e \<rbrakk> \<Longrightarrow> x \<sharp> (\<guillemotleft>f\<guillemotright> e)\<^sub>e"
  by (auto simp add: expr_defs)

lemma unrest_bop:
  "\<lbrakk> x \<sharp> e\<^sub>1; x \<sharp> e\<^sub>2 \<rbrakk> \<Longrightarrow> x \<sharp> (\<guillemotleft>f\<guillemotright> e\<^sub>1 e\<^sub>2)\<^sub>e"
  by (auto simp add: expr_defs)

lemma unrest_trop:
  "\<lbrakk> x \<sharp> e\<^sub>1; x \<sharp> e\<^sub>2; x \<sharp> e\<^sub>3 \<rbrakk> \<Longrightarrow> x \<sharp> (\<guillemotleft>f\<guillemotright> e\<^sub>1 e\<^sub>2 e\<^sub>3)\<^sub>e"
  by (auto simp add: expr_defs)

end