CREATE TABLE "qna_questions" (
	"id" serial PRIMARY KEY NOT NULL,
	"app_id" integer NOT NULL,
	"user_id" integer,
	"title" varchar(256) NOT NULL,
	"body" varchar(65536) NOT NULL,
	"issue_number" integer NOT NULL,
	"issue_url" varchar(500) NOT NULL,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE INDEX "idx_qna_questions_app_id" ON "qna_questions" USING btree ("app_id");--> statement-breakpoint
CREATE INDEX "idx_qna_questions_user_id" ON "qna_questions" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "idx_qna_questions_issue_number" ON "qna_questions" USING btree ("issue_number");--> statement-breakpoint
CREATE INDEX "idx_qna_questions_created_at" ON "qna_questions" USING btree ("created_at");