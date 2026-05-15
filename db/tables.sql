/* Core identities */
CREATE OR ALTER TABLE users (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    gitea_user_id bigint NOT NULL UNIQUE,
    username varchar(255) NOT NULL,
    email varchar(255) NOT NULL UNIQUE,
    is_active boolean NOT NULL DEFAULT true
);

/* Top-level project record. Many lookup tables below are scoped per project. */
CREATE OR ALTER TABLE projects (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_state_id bigint NULL,
    name varchar(255) NOT NULL,
    description text NULL,
    created_by_user_id bigint NULL,
    created_at timestamptz NOT NULL DEFAULT NOW(),
    updated_at timestamptz NOT NULL DEFAULT NOW(),
    is_active boolean NOT NULL DEFAULT true
);

/* Project-scoped lookup tables */
CREATE OR ALTER TABLE project_states (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id bigint NOT NULL,
    state_name varchar(255) NOT NULL,
    CONSTRAINT uq_project_states_name_per_project
        UNIQUE (project_id, state_name),
    CONSTRAINT uq_project_states_project_id_id
        UNIQUE (project_id, id)
);

CREATE OR ALTER TABLE journey_types (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id bigint NOT NULL,
    type_name varchar(255) NOT NULL,
    CONSTRAINT uq_journey_types_name_per_project
        UNIQUE (project_id, type_name),
    CONSTRAINT uq_journey_types_project_id_id
        UNIQUE (project_id, id)
);

CREATE OR ALTER TABLE journey_states (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id bigint NOT NULL,
    state_name varchar(255) NOT NULL,
    CONSTRAINT uq_journey_states_name_per_project
        UNIQUE (project_id, state_name),
    CONSTRAINT uq_journey_states_project_id_id
        UNIQUE (project_id, id)
);

CREATE OR ALTER TABLE story_types (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id bigint NOT NULL,
    type_name varchar(255) NOT NULL,
    CONSTRAINT uq_story_types_name_per_project
        UNIQUE (project_id, type_name),
    CONSTRAINT uq_story_types_project_id_id
        UNIQUE (project_id, id)
);

CREATE OR ALTER TABLE story_states (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id bigint NOT NULL,
    state_name varchar(255) NOT NULL,
    CONSTRAINT uq_story_states_name_per_project
        UNIQUE (project_id, state_name),
    CONSTRAINT uq_story_states_project_id_id
        UNIQUE (project_id, id)
);

CREATE OR ALTER TABLE technical_implementation_types (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id bigint NOT NULL,
    type_name varchar(255) NOT NULL,
    CONSTRAINT uq_technical_implementation_types_name_per_project
        UNIQUE (project_id, type_name),
    CONSTRAINT uq_technical_implementation_types_project_id_id
        UNIQUE (project_id, id)
);

CREATE OR ALTER TABLE technical_implementation_states (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id bigint NOT NULL,
    state_name varchar(255) NOT NULL,
    CONSTRAINT uq_technical_implementation_states_name_per_project
        UNIQUE (project_id, state_name),
    CONSTRAINT uq_technical_implementation_states_project_id_id
        UNIQUE (project_id, id)
);

CREATE OR ALTER TABLE project_themes (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id bigint NOT NULL,
    theme_name varchar(255) NOT NULL,
    CONSTRAINT uq_project_themes_name_per_project
        UNIQUE (project_id, theme_name),
    CONSTRAINT uq_project_themes_project_id_id
        UNIQUE (project_id, id)
);

CREATE OR ALTER TABLE project_areas (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id bigint NOT NULL,
    area_name varchar(255) NOT NULL,
    CONSTRAINT uq_project_areas_name_per_project
        UNIQUE (project_id, area_name),
    CONSTRAINT uq_project_areas_project_id_id
        UNIQUE (project_id, id)
);

CREATE OR ALTER TABLE project_area_components (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_area_id bigint NOT NULL,
    component_name varchar(255) NOT NULL,
    CONSTRAINT uq_project_area_components_name_per_area
        UNIQUE (project_area_id, component_name),
    CONSTRAINT uq_project_area_components_area_id_id
        UNIQUE (project_area_id, id)
);

/* Primary hierarchy: projects -> journeys -> stories -> technical_implementations */
CREATE OR ALTER TABLE journeys (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id bigint NOT NULL,
    journey_type_id bigint NULL,
    journey_state_id bigint NULL,
    name varchar(255) NOT NULL,
    description text NULL,
    created_by_user_id bigint NULL,
    created_at timestamptz NOT NULL DEFAULT NOW(),
    updated_at timestamptz NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_journeys_project_id_id
        UNIQUE (project_id, id)
);

CREATE OR ALTER TABLE stories (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id bigint NOT NULL,
    journey_id bigint NULL,
    sort_order bigint NOT NULL,
    story_type_id bigint NULL,
    story_state_id bigint NULL,
    project_theme_id bigint NULL,
    project_area_id bigint NULL,
    project_area_component_id bigint NULL,
    name varchar(255) NOT NULL,
    description text NULL,
    created_by_user_id bigint NULL,
    created_at timestamptz NOT NULL DEFAULT NOW(),
    updated_at timestamptz NOT NULL DEFAULT NOW(),
    /* A component cannot exist without its parent area being selected. */
    CONSTRAINT chk_stories_project_area_component_requires_area
        CHECK (
            project_area_component_id IS NULL
            OR project_area_id IS NOT NULL
        ),
    CONSTRAINT uq_stories_project_id_id
        UNIQUE (project_id, id)
);

CREATE OR ALTER TABLE technical_implementations (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id bigint NOT NULL,
    story_id bigint NOT NULL,
    sort_order bigint NOT NULL,
    technical_implementation_type_id bigint NULL,
    technical_implementation_state_id bigint NULL,
    name varchar(255) NOT NULL,
    description text NULL,
    created_by_user_id bigint NULL,
    created_at timestamptz NOT NULL DEFAULT NOW(),
    updated_at timestamptz NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_technical_implementations_project_id_id
        UNIQUE (project_id, id)
);

/* Repository hierarchy: projects -> project_repositories -> repositories -> commits */
CREATE OR ALTER TABLE repositories (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    repo_name varchar(255) NOT NULL,
    repo_url varchar(1024) NOT NULL UNIQUE
);

CREATE OR ALTER TABLE project_repositories (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id bigint NOT NULL,
    repository_id bigint NOT NULL,
    CONSTRAINT uq_project_repositories_project_repository
        UNIQUE (project_id, repository_id)
);

CREATE OR ALTER TABLE commits (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    repository_id bigint NOT NULL,
    author varchar(255) NOT NULL,
    commit_url varchar(1024) NOT NULL,
    commit_hash varchar(128) NOT NULL,
    commit_message text NOT NULL,
    indexed_at timestamptz NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_commits_repository_hash
        UNIQUE (repository_id, commit_hash),
    CONSTRAINT uq_commits_repository_id_id
        UNIQUE (repository_id, id)
);

/* Cross-link hierarchy: technical_implementations -> technical_implementation_commits -> commits */
CREATE OR ALTER TABLE technical_implementation_commits (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id bigint NOT NULL,
    technical_implementation_id bigint NOT NULL,
    repository_id bigint NOT NULL,
    commit_id bigint NOT NULL,
    linked_by_user_id bigint NULL,
    linked_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_technical_implementation_commits_pair
        UNIQUE (technical_implementation_id, commit_id)
);

/* Auto-generate sparse sort keys in steps of 64 so siblings can be reordered later. */
CREATE OR REPLACE FUNCTION set_story_sort_order()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.sort_order IS NULL THEN
        IF NEW.journey_id IS NULL THEN
            SELECT COALESCE(MAX(sort_order), 0) + 64
            INTO NEW.sort_order
            FROM stories
            WHERE project_id = NEW.project_id
              AND journey_id IS NULL;
        ELSE
            SELECT COALESCE(MAX(sort_order), 0) + 64
            INTO NEW.sort_order
            FROM stories
            WHERE journey_id = NEW.journey_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION set_technical_implementation_sort_order()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.sort_order IS NULL THEN
        SELECT COALESCE(MAX(sort_order), 0) + 64
        INTO NEW.sort_order
        FROM technical_implementations
        WHERE story_id = NEW.story_id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_stories_set_sort_order
    BEFORE INSERT ON stories
    FOR EACH ROW
    EXECUTE FUNCTION set_story_sort_order();

CREATE OR REPLACE TRIGGER trg_technical_implementations_set_sort_order
    BEFORE INSERT ON technical_implementations
    FOR EACH ROW
    EXECUTE FUNCTION set_technical_implementation_sort_order();

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

/* Foreign keys are added after table creation so the project-scoped composite references
   can point at previously declared UNIQUE(project_id, id) pairs. */
ALTER TABLE projects
    ADD CONSTRAINT fk_projects_created_by_user
        FOREIGN KEY (created_by_user_id)
        REFERENCES users(id);

ALTER TABLE project_states
    ADD CONSTRAINT fk_project_states_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE;

ALTER TABLE journey_types
    ADD CONSTRAINT fk_journey_types_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE;

ALTER TABLE journey_states
    ADD CONSTRAINT fk_journey_states_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE;

ALTER TABLE story_types
    ADD CONSTRAINT fk_story_types_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE;

ALTER TABLE story_states
    ADD CONSTRAINT fk_story_states_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE;

ALTER TABLE technical_implementation_types
    ADD CONSTRAINT fk_technical_implementation_types_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE;

ALTER TABLE technical_implementation_states
    ADD CONSTRAINT fk_technical_implementation_states_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE;

ALTER TABLE project_themes
    ADD CONSTRAINT fk_project_themes_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE;

ALTER TABLE project_areas
    ADD CONSTRAINT fk_project_areas_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE;

ALTER TABLE project_area_components
    ADD CONSTRAINT fk_project_area_components_project_area
        FOREIGN KEY (project_area_id)
        REFERENCES project_areas(id)
        ON DELETE CASCADE;

ALTER TABLE journeys
    ADD CONSTRAINT fk_journeys_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE,
    /* These composite FKs force the selected type/state to belong to the same project. */
    ADD CONSTRAINT fk_journeys_journey_type
        FOREIGN KEY (project_id, journey_type_id)
        REFERENCES journey_types(project_id, id),
    ADD CONSTRAINT fk_journeys_journey_state
        FOREIGN KEY (project_id, journey_state_id)
        REFERENCES journey_states(project_id, id),
    ADD CONSTRAINT fk_journeys_created_by_user
        FOREIGN KEY (created_by_user_id)
        REFERENCES users(id);

ALTER TABLE stories
    ADD CONSTRAINT fk_stories_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE,
    /* Optional journey, but when present it must belong to the same project. */
    ADD CONSTRAINT fk_stories_journey
        FOREIGN KEY (project_id, journey_id)
        REFERENCES journeys(project_id, id),
    ADD CONSTRAINT fk_stories_story_type
        FOREIGN KEY (project_id, story_type_id)
        REFERENCES story_types(project_id, id),
    ADD CONSTRAINT fk_stories_story_state
        FOREIGN KEY (project_id, story_state_id)
        REFERENCES story_states(project_id, id),
    ADD CONSTRAINT fk_stories_project_theme
        FOREIGN KEY (project_id, project_theme_id)
        REFERENCES project_themes(project_id, id),
    ADD CONSTRAINT fk_stories_project_area
        FOREIGN KEY (project_id, project_area_id)
        REFERENCES project_areas(project_id, id),
    /* Component integrity is enforced through its parent project area. */
    ADD CONSTRAINT fk_stories_project_area_component
        FOREIGN KEY (project_area_id, project_area_component_id)
        REFERENCES project_area_components(project_area_id, id),
    ADD CONSTRAINT fk_stories_created_by_user
        FOREIGN KEY (created_by_user_id)
        REFERENCES users(id);

ALTER TABLE technical_implementations
    ADD CONSTRAINT fk_technical_implementations_story
        FOREIGN KEY (project_id, story_id)
        REFERENCES stories(project_id, id)
        ON DELETE CASCADE,
    /* These composite FKs force type/state to come from the same project as the story. */
    ADD CONSTRAINT fk_technical_implementations_type
        FOREIGN KEY (project_id, technical_implementation_type_id)
        REFERENCES technical_implementation_types(project_id, id),
    ADD CONSTRAINT fk_technical_implementations_state
        FOREIGN KEY (project_id, technical_implementation_state_id)
        REFERENCES technical_implementation_states(project_id, id),
    ADD CONSTRAINT fk_technical_implementations_created_by_user
        FOREIGN KEY (created_by_user_id)
        REFERENCES users(id);

ALTER TABLE project_repositories
    ADD CONSTRAINT fk_project_repositories_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE,
    ADD CONSTRAINT fk_project_repositories_repository
        FOREIGN KEY (repository_id)
        REFERENCES repositories(id)
        ON DELETE CASCADE;

ALTER TABLE commits
    ADD CONSTRAINT fk_commits_repository
        FOREIGN KEY (repository_id)
        REFERENCES repositories(id)
        ON DELETE CASCADE;

ALTER TABLE technical_implementation_commits
    ADD CONSTRAINT fk_tic_technical_implementation
        FOREIGN KEY (project_id, technical_implementation_id)
        REFERENCES technical_implementations(project_id, id)
        ON DELETE CASCADE,

    ADD CONSTRAINT fk_tic_project_repository
        FOREIGN KEY (project_id, repository_id)
        REFERENCES project_repositories(project_id, repository_id)
        ON DELETE CASCADE,

    ADD CONSTRAINT fk_tic_commit
        FOREIGN KEY (repository_id, commit_id)
        REFERENCES commits(repository_id, id)
        ON DELETE CASCADE,

    ADD CONSTRAINT fk_tic_linked_by_user
        FOREIGN KEY (linked_by_user_id)
        REFERENCES users(id);

ALTER TABLE projects
    /* Projects choose a state from their own project-scoped state list. */
    ADD CONSTRAINT fk_projects_project_state
        FOREIGN KEY (id, project_state_id)
        REFERENCES project_states(project_id, id);


CREATE INDEX IF NOT EXISTS idx_stories_project_id
    ON stories(project_id);

CREATE INDEX IF NOT EXISTS idx_stories_journey_id
    ON stories(journey_id);

CREATE INDEX IF NOT EXISTS idx_technical_implementations_story_id
    ON technical_implementations(story_id);

CREATE INDEX IF NOT EXISTS idx_project_repositories_repository_id
    ON project_repositories(repository_id);

CREATE INDEX IF NOT EXISTS idx_commits_repository_id
    ON commits(repository_id);

CREATE INDEX IF NOT EXISTS idx_tic_commit_id
    ON technical_implementation_commits(commit_id);

CREATE INDEX IF NOT EXISTS idx_tic_project_repository
    ON technical_implementation_commits(project_id, repository_id);

CREATE INDEX IF NOT EXISTS idx_tic_project_ti
    ON technical_implementation_commits(project_id, technical_implementation_id);