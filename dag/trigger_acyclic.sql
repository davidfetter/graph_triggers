/* 
 * edge_add(new_node_start INTEGER, new_node_end INTEGER)
 * edge_remove(old_node_start INTEGER, old_node_end INTEGER)
 */
CREATE OR REPLACE FUNCTION maintain_tc_acyclic()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO tc
        SELECT * FROM edge_add(NEW.node_start, NEW.node_end);
        RETURN NEW;
    END IF;
    IF TG_OP = 'DELETE' THEN
        DELETE FROM tc
        WHERE NOT EXISTS (
            SELECT 1
            FROM edge_remove(OLD.node_start, OLD.node_end) tcn
            WHERE (tc.node_start, tc.node_end) = (tcn.node_start, tcn.node_end)
        );
        RETURN OLD;
    END IF;
    IF TG_OP = 'UPDATE' THEN
        DELETE FROM tc
        WHERE NOT EXISTS (
            SELECT 1
            FROM edge_remove(OLD.node_start, OLD.node_end) tcn
            WHERE (tc.node_start, tc.node_end) = (tcn.node_start, tcn.node_end)
        );
        INSERT INTO tc
        SELECT * FROM edge_add(NEW.node_start, NEW.node_end);
        RETURN NEW;
    END IF;
    RAISE EXCEPTION 'TG_OP was %, not INSERT, UPDATE, or DELETE', TG_OP;
END;
$$;

CREATE TRIGGER maintain_tc_acyclic
BEFORE INSERT OR UPDATE OR DELETE ON edge
FOR EACH ROW
    EXECUTE PROCEDURE maintain_tc_acyclic();
