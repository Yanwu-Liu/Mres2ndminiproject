import numpy as np

class Ray():
    '''
    Base ray class. After instantiation, propagate the ray through components
    using the propagate method. The ray's vector after each component is added
    to the vector attribute, which is a list of the rays vectors at each 
    component.
    '''

    def __init__(self, position=0.0, direction=0.0):

        self.vector = [np.array([[position], [direction]]), ]
        self.z_distance = [0.0]

    def current_vector(self):

        return self.vector[-1]

    def append(self, new_vector):

        self.vector.append(new_vector)

    def propagate(self, component):

        if isinstance(component, Mirror):
            self.append(self.current_vector() +
                        np.array([[0.0], [component.angle*(np.pi/180.)]]))
        if isinstance(component, Misalignment):
            self.append(self.current_vector() +
                        np.array([[component.lateral], [component.angular]]))
        else:
            self.append(component.transfer_matrix.dot(self.current_vector()))

        self.z_distance.append(self.z_distance[-1] + component.distance)


class GaussianBeam():
    
    '''
    Gaussian beam model based on two paraxial rays. The upper and lower 1/e**2 
    radius can be calculated using the respective methods
    '''
    
    def __init__(self, position, direction, w_0, wavelength):

        r_0 = w_0/2  # convert diameter to radius

        self.upper_waist_ray = Ray(r_0 + position, direction)
        self.centre_ray = Ray(position, direction)
        self.lower_waist_ray = Ray(position - r_0, direction)
        self.upper_skew_ray = Ray(position, direction + wavelength/(np.pi*r_0))
        self.lower_skew_ray = Ray(position, direction - wavelength/(np.pi*r_0))

    def beam_radius_upper(self):

        radius = []

        for centre, waist, skew in zip(self.centre_ray.vector, self.upper_waist_ray.vector, self.upper_skew_ray.vector):

            waist_t = waist[0, 0] - centre[0, 0]
            skew_t = skew[0, 0] - centre[0, 0]

            point = (waist_t**2+skew_t**2)**0.5

            radius.append(point+centre[0, 0])

        return radius

    def beam_radius_lower(self):

        radius = []

        for centre, waist, skew in zip(self.centre_ray.vector, self.lower_waist_ray.vector, self.lower_skew_ray.vector):

            waist_t = waist[0, 0] - centre[0, 0]
            skew_t = skew[0, 0] - centre[0, 0]

            point = (waist_t**2+skew_t**2)**0.5

            radius.append(-point+centre[0, 0])

        return radius

    def propagate(self, component):

        self.upper_waist_ray.propagate(component)
        self.centre_ray.propagate(component)
        self.lower_waist_ray.propagate(component)
        self.upper_skew_ray.propagate(component)
        self.lower_skew_ray.propagate(component)




        


class FreeSpace():

    def __init__(self, distance):

        self.distance = distance
        self.transfer_matrix = np.array([[1, distance], [0, 1]])


class ThinLens():

    def __init__(self, focal_length):

        self.distance = 0.0
        self.transfer_matrix = np.array([[1, 0], [-1./focal_length, 1]])


    #calculated maximum distance to maintain collimation. 
    #MFD is incident fibre MFD
    def lens_maximum_working_distance(self, focal_length, wavelength, MFD):
    
        zmax  = (4*(focal_length**2)*wavelength)/(np.pi*(MFD**2))
        return zmax         








class Mirror():
    
    def __init__(self, angle):

        self.angle = angle
        self.distance = 0.0


class Misalignment():
    
    '''
    Adds lateral and angular values to the current vector to simulate a 
    misalignment in the system.
    '''
    
    def __init__(self, lateral, angular):

        self.distance = 0.0
        self.lateral = lateral
        self.angular = angular


def FreeSpaceIterator(beam, distance, samples):

    '''
    A function that iterates the free space component in small steps so that 
    the evolution of the Gaussian beam across the free space can be seen. 
    Useful for visualisation but just call FreeSpace directly only care about 
    the beam at the start/end of the free space.
    '''    

    step = distance/samples

    for _ in range(samples):

        segment = FreeSpace(step)
        beam.propagate(segment)


'''
class Component():

	def propagate(self, ray):

		ray.append(self.transfer_matrix.dot(ray.current_vector()))

class GaussianBeamOld():

	def __init__(self, z, w_0, wavelength):

		self.wavelength = wavelength
		
		beam_parameter = z + ((1j*np.pi)*w_0**2)/wavelength

		self.vector = [beam_parameter]		

	def current_vector(self):

		return self.vector[-1]

	def append(self,new_vector):

		self.vector.append(new_vector)

	def beam_radius(self):

		beam_radius = [(((q.imag*self.wavelength)/np.pi)*(1+(q.real/q.imag)**2))**0.5 for q in self.vector]

		#beam_radius = [ np.sqrt((q.imag*self.wavelength)/np.pi) for q in self.vector]
		return beam_radius

	def propagate(self, component):
		
		M = component.transfer_matrix
		q = self.current_vector()

		new_beam_parameter = (M[0,0]*q + M[0,1])/((M[1,0]*q + M[1,1]))

		self.append(new_beam_parameter)
'''
