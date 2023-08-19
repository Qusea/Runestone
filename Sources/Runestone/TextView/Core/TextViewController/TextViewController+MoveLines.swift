import Foundation

extension TextViewController {
    func moveSelectedLinesUp() {
        moveSelectedLine(byOffset: -1, undoActionName: L10n.Undo.ActionName.moveLinesUp)
    }

    func moveSelectedLinesDown() {
        moveSelectedLine(byOffset: 1, undoActionName: L10n.Undo.ActionName.moveLinesDown)
    }
}

private extension TextViewController {
    private func moveSelectedLine(byOffset lineOffset: Int, undoActionName: String) {
        guard let oldSelectedRange = selectedRange else {
            return
        }
        let moveLinesService = MoveLinesService(stringView: stringView, lineManager: lineManager, lineEndingSymbol: lineEndings.symbol)
        guard let operation = moveLinesService.operationForMovingLines(in: oldSelectedRange, byOffset: lineOffset) else {
            return
        }
        timedUndoManager.endUndoGrouping()
        timedUndoManager.beginUndoGrouping()
        addUndoOperationForReplacingText(in: operation.removeRange, with: "", actionName: undoActionName)
        replaceText(in: operation.removeRange, with: "")
        addUndoOperationForReplacingText(in: operation.replacementRange, with: operation.replacementString, actionName: undoActionName)
        replaceText(in: operation.replacementRange, with: operation.replacementString)
        #if os(iOS) || os(xrOS)
        textView.notifyInputDelegateAboutSelectionChangeInLayoutSubviews = true
        #endif
        selectedRange = operation.selectedRange
        timedUndoManager.endUndoGrouping()
    }
}
