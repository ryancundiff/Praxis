--[=[
    @class Bezier

	A utility module for working with Bezier curves.
]=]

local Bezier = {}

-- Types
export type BezierPoint = number | Vector2 | Vector3

local function LerpPoints(StartPoint: BezierPoint, EndPoint: BezierPoint, AlphaValue: number): BezierPoint
	return (StartPoint :: any) + ((EndPoint :: any) - (StartPoint :: any)) * AlphaValue
end

--[=[
	@param StartPoint BezierPoint -- Starting point
	@param EndPoint BezierPoint -- End point
	@param AlphaValue number -- Interpolation alpha from 0 to 1
	@return BezierPoint

    Linearly interpolates between two points.
]=]

function Bezier.Lerp(StartPoint: BezierPoint, EndPoint: BezierPoint, AlphaValue: number): BezierPoint
	return LerpPoints(StartPoint, EndPoint, math.clamp(AlphaValue, 0, 1))
end

--[=[
	@param ControlPoints {BezierPoint} -- Curve control points, minimum of 2
	@param AlphaValue number -- Position on curve from 0 to 1
	@return BezierPoint

    Evaluates a Bezier curve at t using De Casteljau's algorithm.
]=]

function Bezier.Evaluate(ControlPoints: { BezierPoint }, AlphaValue: number): BezierPoint
	if #ControlPoints < 2 then
		error("Bezier requires at least 2 control points")
	end

	local ClampedAlphaValue = math.clamp(AlphaValue, 0, 1)
	local WorkingPoints = table.clone(ControlPoints)

	for CurrentRowSize = #WorkingPoints, 2, -1 do
		for PointIndex = 1, CurrentRowSize - 1 do
			WorkingPoints[PointIndex] = LerpPoints(WorkingPoints[PointIndex], WorkingPoints[PointIndex + 1], ClampedAlphaValue)
		end
	end

	return WorkingPoints[1]
end

--[=[
	@param StartPoint BezierPoint -- Start point
	@param ControlPoint BezierPoint -- Handle point
	@param EndPoint BezierPoint -- End point
	@param AlphaValue number -- Position on curve from 0 to 1
	@return BezierPoint

    Evaluates a quadratic Bezier curve (3 points) at t.
]=]

function Bezier.Quadratic(StartPoint: BezierPoint, ControlPoint: BezierPoint, EndPoint: BezierPoint, AlphaValue: number): BezierPoint
	return Bezier.Evaluate({ StartPoint, ControlPoint, EndPoint }, AlphaValue)
end

--[=[
    @param StartPoint BezierPoint -- Start point
	@param FirstControlPoint BezierPoint -- First handle point
	@param SecondControlPoint BezierPoint -- Second handle point
	@param EndPoint BezierPoint -- End point
	@param AlphaValue number -- Position on curve from 0 to 1
	@return BezierPoint

	Evaluates a cubic Bezier curve (4 points) at t.
]=]

function Bezier.Cubic(StartPoint: BezierPoint, FirstControlPoint: BezierPoint, SecondControlPoint: BezierPoint, EndPoint: BezierPoint, AlphaValue: number): BezierPoint
	return Bezier.Evaluate({ StartPoint, FirstControlPoint, SecondControlPoint, EndPoint }, AlphaValue)
end

--[=[
	@param ControlPoints {BezierPoint} -- Curve control points, minimum of 2
	@param AlphaValue number -- Position on curve from 0 to 1
	@return BezierPoint

    Gets a tangent direction vector/value at t.

	For Vector2 and Vector3 points, this returns a unit direction when possible.
	For number points, this returns the scalar derivative value.
]=]

function Bezier.Tangent(ControlPoints: { BezierPoint }, AlphaValue: number): BezierPoint
	if #ControlPoints < 2 then
		error("Bezier requires at least 2 control points")
	end

	local DerivativeControlPoints = {}
	local CurveDegree = #ControlPoints - 1

	for ControlPointIndex = 1, CurveDegree do
		DerivativeControlPoints[ControlPointIndex] = ((ControlPoints[ControlPointIndex + 1] :: any) - (ControlPoints[ControlPointIndex] :: any)) * CurveDegree
	end

	local TangentPoint = Bezier.Evaluate(DerivativeControlPoints, AlphaValue)
	local TangentPointType = typeof(TangentPoint)

	if TangentPointType == "Vector2" then
		local TangentMagnitude = (TangentPoint :: Vector2).Magnitude
		if TangentMagnitude == 0 then
			return TangentPoint
		end
		return (TangentPoint :: Vector2).Unit
	elseif TangentPointType == "Vector3" then
		local TangentMagnitude = (TangentPoint :: Vector3).Magnitude
		if TangentMagnitude == 0 then
			return TangentPoint
		end
		return (TangentPoint :: Vector3).Unit
	end

	return TangentPoint
end

--[=[
	@param ControlPoints {BezierPoint} -- Curve control points, minimum of 2
	@param AlphaValue number -- Position on curve from 0 to 1
	@return {BezierPoint}, {BezierPoint} -- Left and right control point arrays

    Splits a Bezier curve into left and right curves at t.
]=]

function Bezier.Split(ControlPoints: { BezierPoint }, AlphaValue: number): ({ BezierPoint }, { BezierPoint })
	if #ControlPoints < 2 then
		error("Bezier requires at least 2 control points")
	end

	local ClampedAlphaValue = math.clamp(AlphaValue, 0, 1)
	local WorkingPoints = table.clone(ControlPoints)
	local LeftControlPoints = { WorkingPoints[1] }
	local RightControlPoints = { WorkingPoints[#WorkingPoints] }

	for CurrentRowSize = #WorkingPoints, 2, -1 do
		for PointIndex = 1, CurrentRowSize - 1 do
			WorkingPoints[PointIndex] = LerpPoints(WorkingPoints[PointIndex], WorkingPoints[PointIndex + 1], ClampedAlphaValue)
		end

		table.insert(LeftControlPoints, WorkingPoints[1])
		table.insert(RightControlPoints, 1, WorkingPoints[CurrentRowSize - 1])
	end

	return LeftControlPoints, RightControlPoints
end

--[=[
	@param ControlPoints {BezierPoint} -- Curve control points, minimum of 2
	@param SegmentCount number -- Number of line segments to generate, minimum 1
	@return {BezierPoint}

    Samples a Bezier curve into evenly spaced t-steps.
]=]

function Bezier.Sample(ControlPoints: { BezierPoint }, SegmentCount: number): { BezierPoint }
	if #ControlPoints < 2 then
		error("Bezier requires at least 2 control points")
	end

	if SegmentCount < 1 then
		error("SegmentCount must be at least 1")
	end

	local RoundedSegmentCount = math.floor(SegmentCount)
	local SampledPoints = table.create(RoundedSegmentCount + 1)

	for SegmentIndex = 0, RoundedSegmentCount do
		SampledPoints[SegmentIndex + 1] = Bezier.Evaluate(ControlPoints, SegmentIndex / RoundedSegmentCount)
	end

	return SampledPoints
end

--[=[
	@param ControlPoints {BezierPoint} -- Curve control points, minimum of 2
	@param SegmentCount number -- Number of segments for approximation, minimum 1
	@return number

    Approximates curve length by sampling line segments.

	Only Vector2 and Vector3 curves support length approximation.
]=]

function Bezier.ApproximateLength(ControlPoints: { BezierPoint }, SegmentCount: number): number
	if #ControlPoints < 2 then
		error("Bezier requires at least 2 control points")
	end

	local FirstControlPointType = typeof(ControlPoints[1])
	if FirstControlPointType ~= "Vector2" and FirstControlPointType ~= "Vector3" then
		error(`ApproximateLength only supports Vector2/Vector3 points; got {FirstControlPointType}`)
	end

	local SampledPoints = Bezier.Sample(ControlPoints, SegmentCount)
	local TotalLength = 0

	for SampleIndex = 2, #SampledPoints do
		local SampleDelta = (SampledPoints[SampleIndex] :: any) - (SampledPoints[SampleIndex - 1] :: any)
		TotalLength += SampleDelta.Magnitude
	end

	return TotalLength
end

return Bezier
