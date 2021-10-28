package org.ehrbase.api.aop;

import com.nedap.archie.rm.composition.Composition;

public interface CompositionPostCommitListener {

  void listen(Composition composition);
}
