import { useTexture } from '@react-three/drei'
import { useMemo, useRef } from 'react'
import * as THREE from 'three'
import { Vector3 } from 'three'
import type { IimageShaderMaterial } from './Experience'


export const carouselRadius = 26
export const carouselCount = 12
export const numPoints = 16 * 60
export const progressLength = 0.916

export const MOMENTUM_DECAY = 0.99
export const MOMENTUM_BOOST = 0.02
export const BASE_SPEED = 0.1

// const carouselAxisAngle = new Vector3(-0.5, -1, 0)
// const carouselAngle = -0.4

const carouselPoints = new Array(carouselCount).fill(undefined).map((_, i) => {
	const v = new Vector3()
	v.x = Math.sin(((carouselCount - 1 - i) / carouselCount) * Math.PI * 2) * carouselRadius
	v.y = 15
	v.z = Math.cos(((carouselCount - 1 - i) / carouselCount) * Math.PI * 2) * carouselRadius
	// v.applyAxisAngle(carouselAxisAngle, carouselAngle)
	v.applyEuler(new THREE.Euler(0, 0.0, -0.1))
	// v.applyQuaternion( new THREE.Quaternion().setFromAxisAngle(new Vector3(0,0,1), Math.PI / 8))
	return v
})

export const baseCurvePoints: Vector3[] = [
	new Vector3(-20, 10, -70),
	new Vector3(50, 30, -80),
	new Vector3(30, 30, -75),
	new Vector3(50, 30, -70),
	new Vector3(30, 30, -65),
	new Vector3(50, 30, -60),
	new Vector3(50, 10, -45),
	new Vector3(35, 4, -35),
	new Vector3(20, -10, -60),
	new Vector3(-10, 20, -30),
	new Vector3(10, 30, -22),
	new Vector3(0, 25, -11),
	// new Vector3(-30, 10, 20),
	...carouselPoints,
	new Vector3(carouselPoints[0].x - 10, carouselPoints[0].y + 20, carouselPoints[0].z + 20),
	new Vector3(60, 35, -30),
	new Vector3(30, 20, -30),
	new Vector3(20, 10, -35),
	new Vector3(10, 15, -48),
	new Vector3(5, 15, -58),
	new Vector3(25, 10, -85),
	new Vector3(50, -16, -82),
]

export function useLinenTextures() {
	const col = useTexture('http://localhost:5173/linen/Plain_Grey_Texture_col.jpg')
	const normal = useTexture('http://localhost:5173/linen/Plain_Grey_Texture_nrm.jpg')

	for (const t of [col, normal]) {
		t.wrapS = t.wrapT = THREE.RepeatWrapping
		t.needsUpdate = true
	}
	col.colorSpace = THREE.SRGBColorSpace

	return { col, normal }
}


export function useCarouselImages() {
	const imageUrls = useMemo(
		() =>
			Array(carouselCount)
				.fill(undefined)
				.map((_, i) => `http://localhost:5173/images/img${Math.floor(i % carouselCount) + 1}_.webp`),
		[]
	)
	const imageTextures = useTexture(imageUrls)
	const imageShaderRefs = useRef<(IimageShaderMaterial | null)[]>([])
	useMemo(() => {
		imageShaderRefs.current = Array(carouselCount).fill(null)
	}, [])

	return { imageUrls, imageTextures, imageShaderRefs }
}


export function useMomentum() {
	const momentum = useRef(0)
	const wasAtCarousel = useRef(false)
	return { momentum, wasAtCarousel }
}

export function useFrenetDataTexture(
	curve: THREE.CatmullRomCurve3,
	cPoints: Vector3[],
	numPoints: number
): THREE.DataTexture {
	return useMemo(() => {
		// compute Frenet frames once
		const { binormals, normals, tangents } = curve.computeFrenetFrames(numPoints, false)

		// pack into a flat array
		const data: number[] = []
		cPoints.forEach(v => data.push(v.x, v.y, v.z))
		binormals.forEach(v => data.push(v.x, v.y, v.z))
		normals.forEach(v => data.push(v.x, v.y, v.z))
		tangents.forEach(v => data.push(v.x, v.y, v.z))

		// build the DataTexture
		const tex = new THREE.DataTexture(
			new Float32Array(data),
			numPoints + 1,
			4,
			THREE.RGBFormat,
			THREE.FloatType
		)
		tex.internalFormat = 'RGB32F'
		tex.magFilter = THREE.NearestFilter
		tex.minFilter = THREE.NearestFilter
		tex.generateMipmaps = false
		tex.needsUpdate = true
		return tex
	}, [curve, cPoints, numPoints])
}

